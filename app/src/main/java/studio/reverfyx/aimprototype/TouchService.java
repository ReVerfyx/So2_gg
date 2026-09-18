package studio.reverfyx.aimprototype;
import android.accessibilityservice.*;
import android.graphics.Path;
import android.view.accessibility.*;
import android.os.*;

public class TouchService extends AccessibilityService {
 public static TouchService instance;
 private boolean busy;
 @Override protected void onServiceConnected(){instance=this;}
 @Override public void onAccessibilityEvent(AccessibilityEvent event) {}
 @Override public void onInterrupt(){busy=false;CaptureService.disarm();}
 @Override public void onDestroy(){instance=null;CaptureService.disarm();super.onDestroy();}
 public boolean inGame(){
  AccessibilityNodeInfo root=getRootInActiveWindow();
  if(root==null)return false;
  return "com.axlebolt.standoff2".contentEquals(root.getPackageName()==null?"":root.getPackageName());
 }
 public void move(float x,float y,float dx,float dy,boolean fire,float fx,float fy){
  if(busy||!inGame())return;
  GestureDescription.Builder b=new GestureDescription.Builder();
  if(Math.abs(dx)+Math.abs(dy)>.1f){Path p=new Path();p.moveTo(x,y);p.lineTo(x+dx,y+dy);b.addStroke(new GestureDescription.StrokeDescription(p,0,80));}
  if(fire){Path p=new Path();p.moveTo(fx,fy);b.addStroke(new GestureDescription.StrokeDescription(p,0,80));}
  if(Math.abs(dx)+Math.abs(dy)<=.1f&&!fire)return;
  busy=true;
  try {boolean accepted=dispatchGesture(b.build(),new GestureResultCallback(){
   @Override public void onCompleted(GestureDescription g){busy=false;}
   @Override public void onCancelled(GestureDescription g){busy=false;}
  },new Handler(Looper.getMainLooper())); if(!accepted)busy=false;
  }catch(RuntimeException e){busy=false;CaptureService.disarm();}
 }
}
