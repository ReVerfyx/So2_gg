package studio.reverfyx.aimprototype;
import android.app.*;
import android.content.*;
import android.content.pm.ServiceInfo;
import android.content.res.Configuration;
import android.graphics.*;
import android.hardware.display.*;
import android.media.*;
import android.media.projection.*;
import android.os.*;
import android.util.DisplayMetrics;
import android.view.*;
import android.widget.*;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.pose.*;
import com.google.mlkit.vision.pose.defaults.PoseDetectorOptions;

public class CaptureService extends Service {
 public static boolean running;
 private static CaptureService active;
 final Handler main=new Handler(Looper.getMainLooper());
 MediaProjection projection; VirtualDisplay display; ImageReader reader; PoseDetector detector;
 WindowManager wm; LinearLayout panel; TextView status; Button aimButton,burstButton;
 android.content.SharedPreferences prefs;
 int width,height,rotation; boolean processing,closed,armed,burst;
 long lastFrame,lastPose; float tx,ty; boolean detected; int stable;
 String error="";
 public static void disarm(){if(active!=null){active.armed=false;active.burst=false;}}
 @Override public IBinder onBind(Intent i){return null;}
 @Override public int onStartCommand(Intent i,int flags,int id){
  if(i==null||"STOP".equals(i.getAction())){stopSelf();return START_NOT_STICKY;}
  if(running)return START_NOT_STICKY;
  try {
   getSystemService(NotificationManager.class).createNotificationChannel(new NotificationChannel("capture","Захват экрана",NotificationManager.IMPORTANCE_LOW));
   PendingIntent stop=PendingIntent.getService(this,1,new Intent(this,CaptureService.class).setAction("STOP"),PendingIntent.FLAG_IMMUTABLE|PendingIntent.FLAG_UPDATE_CURRENT);
   Notification n=new Notification.Builder(this,"capture").setSmallIcon(android.R.drawable.ic_menu_view).setContentTitle("Aim Prototype: захват экрана").setContentText("Нажмите, чтобы остановить").setContentIntent(stop).setOngoing(true).addAction(new Notification.Action.Builder(null,"Стоп",stop).build()).build();
   if(Build.VERSION.SDK_INT>=29)startForeground(1,n,ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION);else startForeground(1,n);
   prefs=getSharedPreferences("config",0);wm=(WindowManager)getSystemService(WINDOW_SERVICE);
   DisplayMetrics metrics=new DisplayMetrics();wm.getDefaultDisplay().getRealMetrics(metrics);width=metrics.widthPixels;height=metrics.heightPixels;rotation=wm.getDefaultDisplay().getRotation();
   if(width<height)throw new IllegalStateException("Запускайте в альбомной ориентации");
   Intent data=i.getParcelableExtra("data");
   projection=((MediaProjectionManager)getSystemService(MEDIA_PROJECTION_SERVICE)).getMediaProjection(i.getIntExtra("code",0),data);
   projection.registerCallback(new MediaProjection.Callback(){@Override public void onStop(){stopSelf();}},main);
   detector=PoseDetection.getClient(new PoseDetectorOptions.Builder().setDetectorMode(PoseDetectorOptions.STREAM_MODE).build());
   reader=ImageReader.newInstance(width,height,PixelFormat.RGBA_8888,2);
   reader.setOnImageAvailableListener(this::frame,main);
   display=projection.createVirtualDisplay("AimCapture",width,height,metrics.densityDpi,DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,reader.getSurface(),null,main);
   overlay();running=true;active=this;main.post(tick);
  }catch(Exception e){Toast.makeText(this,"Не удалось запустить: "+e.getMessage(),Toast.LENGTH_LONG).show();stopSelf();}
  return START_NOT_STICKY;
 }
 float setting(String key,float fallback){return prefs.getFloat(key,fallback);}
 void overlay(){
  panel=new LinearLayout(this);panel.setOrientation(1);panel.setPadding(8,4,8,4);panel.setBackgroundColor(0xdd16202b);
  status=new TextView(this);status.setTextColor(Color.WHITE);status.setTextSize(11);panel.addView(status);
  LinearLayout row=new LinearLayout(this);panel.addView(row);
  aimButton=new Button(this);aimButton.setTextSize(10);row.addView(aimButton);aimButton.setOnClickListener(v->{armed=!armed;burst=false;});
  burstButton=new Button(this);burstButton.setTextSize(10);row.addView(burstButton);burstButton.setOnClickListener(v->{burst=!burst;armed=false;});
  Button stop=new Button(this);stop.setText("Стоп");stop.setTextSize(10);row.addView(stop);stop.setOnClickListener(v->stopSelf());
  WindowManager.LayoutParams lp=new WindowManager.LayoutParams(WindowManager.LayoutParams.WRAP_CONTENT,WindowManager.LayoutParams.WRAP_CONTENT,WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,PixelFormat.TRANSLUCENT);lp.gravity=Gravity.TOP|Gravity.LEFT;lp.x=20;lp.y=10;
  status.setOnTouchListener(new View.OnTouchListener(){float sx,sy;int ox,oy;public boolean onTouch(View v,android.view.MotionEvent e){if(e.getAction()==0){sx=e.getRawX();sy=e.getRawY();ox=lp.x;oy=lp.y;}else if(e.getAction()==2){lp.x=(int)AimMath.clamp(ox+e.getRawX()-sx,0,Math.max(0,width-panel.getWidth()));lp.y=(int)AimMath.clamp(oy+e.getRawY()-sy,0,Math.max(0,height-panel.getHeight()));wm.updateViewLayout(panel,lp);}return true;}});
  wm.addView(panel,lp);
 }
 void frame(ImageReader source){
  Image image=null;
  try {
   image=source.acquireLatestImage();if(image==null)return;
   long now=SystemClock.elapsedRealtime();
   if(closed||processing||now-lastFrame<120||TouchService.instance==null||!TouchService.instance.inGame())return;
   lastFrame=now;
   Image.Plane plane=image.getPlanes()[0];int padded=plane.getRowStride()/plane.getPixelStride();
   Bitmap raw=Bitmap.createBitmap(padded,height,Bitmap.Config.ARGB_8888);raw.copyPixelsFromBuffer(plane.getBuffer());
   Bitmap crop=Bitmap.createBitmap(raw,0,0,width,height);if(crop!=raw)raw.recycle();
   float scale=Math.min(1f,Math.max(720f/width,360f/height));Bitmap scaled=Bitmap.createScaledBitmap(crop,Math.round(width*scale),Math.round(height*scale),true);if(scaled!=crop)crop.recycle();
   processing=true;final long captured=now;final float sx=width/(float)scaled.getWidth(),sy=height/(float)scaled.getHeight();
   detector.process(InputImage.fromBitmap(scaled,0)).addOnSuccessListener(p->{if(!closed)pose(p,captured,sx,sy);}).addOnFailureListener(e->{detected=false;stable=0;error="Ошибка модели: "+e.getClass().getSimpleName();}).addOnCompleteListener(t->{scaled.recycle();processing=false;});
  }catch(Exception e){detected=false;stable=0;error="Ошибка кадра: "+e.getClass().getSimpleName();}
  finally{if(image!=null)image.close();}
 }
 void pose(Pose pose,long captured,float sx,float sy){
  int mode=prefs.getInt("target",0);int[] ids=mode==0?new int[]{PoseLandmark.NOSE}:mode==1?new int[]{PoseLandmark.LEFT_SHOULDER,PoseLandmark.RIGHT_SHOULDER,PoseLandmark.LEFT_HIP,PoseLandmark.RIGHT_HIP}:new int[]{PoseLandmark.LEFT_KNEE,PoseLandmark.RIGHT_KNEE};
  float x=0,y=0;
  for(int id:ids){PoseLandmark l=pose.getPoseLandmark(id);if(l==null||l.getInFrameLikelihood()<setting("confidence",.8f)){detected=false;stable=0;return;}x+=l.getPosition().x*sx;y+=l.getPosition().y*sy;}
  x/=ids.length;y/=ids.length;
  if(detected&&Math.hypot(tx-x,ty-y)<Math.min(width,height)*.15f)stable++;else stable=1;
  tx=x;ty=y;lastPose=captured;detected=true;error="";
 }
 final Runnable tick=new Runnable(){@Override public void run(){
  if(closed)return;
  if(wm.getDefaultDisplay().getRotation()!=rotation){Toast.makeText(CaptureService.this,"Экран повернулся. Запустите захват заново.",Toast.LENGTH_LONG).show();stopSelf();return;}
  TouchService touch=TouchService.instance;boolean game=touch!=null&&touch.inGame();
  if(!game){armed=false;burst=false;detected=false;stable=0;}
  long age=SystemClock.elapsedRealtime()-lastPose;
  boolean valid=detected&&stable>=2&&AimMath.eligible(tx,ty,width,height,Math.min(width,height)*setting("radius",25)/100f,age);
  status.setText(!game?"Ожидание Standoff 2 / нет доступа к окну":!error.isEmpty()?error:valid?"Фигура найдена • "+age+" мс • тяните эту строку":"Нет уверенной цели • тяните эту строку");
  aimButton.setText(armed?"AIM: вкл":"AIM: выкл");burstButton.setText(burst?"Очередь: вкл":"Очередь: выкл");
  if(game&&(burst||(armed&&valid))){
   float ex=tx-width/2f,ey=ty-height/2f;
   boolean fire=burst||(prefs.getBoolean("trigger",false)&&Math.hypot(ex,ey)<=10);
   float dx=armed?AimMath.correction(ex,setting("gain",.15f),40):0;
   float dy=(armed?AimMath.correction(ey,setting("gain",.15f),40):0)+(fire?setting("recoil",5):0);
   float x=width*setting("dragX",75)/100f,y=height*setting("dragY",50)/100f;
   dx=AimMath.clamp(x+dx,1,width-2)-x;dy=AimMath.clamp(y+dy,1,height-2)-y;
   touch.move(x,y,dx,dy,fire,width*setting("fireX",90)/100f,height*setting("fireY",70)/100f);
  }
  main.postDelayed(this,120);
 }};
 @Override public void onConfigurationChanged(Configuration c){super.onConfigurationChanged(c);disarm();}
 @Override public void onDestroy(){
  closed=true;running=false;if(active==this)active=null;armed=false;burst=false;main.removeCallbacksAndMessages(null);
  if(panel!=null&&wm!=null){try{wm.removeView(panel);}catch(Exception ignored){}}
  if(display!=null)display.release();if(reader!=null)reader.close();if(projection!=null)projection.stop();if(detector!=null)detector.close();
  stopForeground(STOP_FOREGROUND_REMOVE);super.onDestroy();
 }
}
