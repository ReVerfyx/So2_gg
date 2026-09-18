package studio.reverfyx.aimprototype;
import android.app.*;
import android.os.*;
import android.content.*;
import android.content.pm.PackageManager;
import android.media.projection.*;
import android.net.Uri;
import android.provider.Settings;
import android.text.InputType;
import android.widget.*;
import java.util.LinkedHashMap;

public class MainActivity extends Activity {
 final LinkedHashMap<String,EditText> fields=new LinkedHashMap<>();
 Spinner target; Switch trigger; android.content.SharedPreferences prefs;
 @Override public void onCreate(Bundle b) {
  super.onCreate(b);
  getWindow().getDecorView().setSystemUiVisibility(5894);
  prefs=getSharedPreferences("config",0);
  LinearLayout col=new LinearLayout(this); col.setOrientation(LinearLayout.VERTICAL); col.setPadding(28,16,28,20);
  ScrollView scroll=new ScrollView(this); scroll.addView(col); setContentView(scroll);
  TextView title=new TextView(this); title.setText("Aim Prototype • эксперимент"); title.setTextSize(24); col.addView(title);
  TextView info=new TextView(this); info.setText("Модель ищет одну фигуру, не различает команды и не обучена Standoff 2. ВХ отсутствует. Автожесты прерывают ручные касания. Сначала проверьте обнаружение с выключенным AIM. Кадры не сохраняются."); col.addView(info);
  button(col,"1. Разрешить поверх других окон",()->startActivity(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,Uri.parse("package:"+getPackageName()))));
  button(col,"2. Включить Aim Prototype в специальных возможностях",()->startActivity(new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)));
  target=new Spinner(this); target.setAdapter(new ArrayAdapter<>(this,android.R.layout.simple_spinner_dropdown_item,new String[]{"Голова (нос)","Тело (центр торса)","Ноги (середина коленей)"})); target.setSelection(prefs.getInt("target",0)); col.addView(target);
  field(col,"gain","Коэффициент движения (от −1 до 1)",0.15f);
  field(col,"radius","Радиус захвата: % короткой стороны (5–50)",25);
  field(col,"confidence","Порог уверенности (0.5–0.99)",0.8f);
  field(col,"recoil","Макрос: движение вниз за импульс, px (0–60)",5);
  field(col,"dragX","Область обзора X, % (5–95)",75);
  field(col,"dragY","Область обзора Y, % (5–95)",50);
  field(col,"fireX","Кнопка стрельбы X, % (5–95)",90);
  field(col,"fireY","Кнопка стрельбы Y, % (5–95)",70);
  trigger=new Switch(this); trigger.setText("Автовыстрел при совпадении с прицелом (±10 px)"); trigger.setChecked(prefs.getBoolean("trigger",false)); col.addView(trigger);
  button(col,"3. Сохранить и запустить захват",()->{
   if(!save())return;
   if(!Settings.canDrawOverlays(this)){toast("Сначала разрешите отображение поверх окон");return;}
   if(TouchService.instance==null){toast("Сначала включите службу специальных возможностей");return;}
   if(CaptureService.running){toast("Захват уже запущен. Остановите его перед изменением настроек.");return;}
   if(Build.VERSION.SDK_INT>=33 && checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS)!=PackageManager.PERMISSION_GRANTED) requestPermissions(new String[]{android.Manifest.permission.POST_NOTIFICATIONS},5);
   MediaProjectionManager m=(MediaProjectionManager)getSystemService(MEDIA_PROJECTION_SERVICE);
   Intent request=Build.VERSION.SDK_INT>=34 ? m.createScreenCaptureIntent(MediaProjectionConfig.createConfigForDefaultDisplay()) : m.createScreenCaptureIntent();
   startActivityForResult(request,7);
  });
  button(col,"Остановить",()->stopService(new Intent(this,CaptureService.class)));
 }
 void button(LinearLayout l,String text,Runnable r){Button b=new Button(this);b.setText(text);b.setOnClickListener(v->r.run());l.addView(b);}
 void field(LinearLayout l,String key,String label,float def){TextView t=new TextView(this);t.setText(label);l.addView(t);EditText e=new EditText(this);e.setSingleLine();e.setInputType(InputType.TYPE_CLASS_NUMBER|InputType.TYPE_NUMBER_FLAG_DECIMAL|InputType.TYPE_NUMBER_FLAG_SIGNED);e.setText(Float.toString(prefs.getFloat(key,def)));fields.put(key,e);l.addView(e);}
 boolean save(){
  android.content.SharedPreferences.Editor edit=prefs.edit();
  try { for(String k:fields.keySet()){
   float v=Float.parseFloat(fields.get(k).getText().toString().replace(',','.'));
   float min=5,max=95;
   if(k.equals("gain")){min=-1;max=1;} else if(k.equals("radius")){min=5;max=50;} else if(k.equals("confidence")){min=.5f;max=.99f;} else if(k.equals("recoil")){min=0;max=60;}
   if(!Float.isFinite(v)||v<min||v>max)throw new IllegalArgumentException(k+": допустимо "+min+" … "+max);
   edit.putFloat(k,v);
  }
  edit.putInt("target",target.getSelectedItemPosition()).putBoolean("trigger",trigger.isChecked()).apply();return true;
  }catch(Exception e){toast("Проверьте настройки: "+e.getMessage());return false;}
 }
 @Override protected void onActivityResult(int request,int result,Intent data){super.onActivityResult(request,result,data);if(request==7&&result==RESULT_OK&&data!=null){Intent i=new Intent(this,CaptureService.class).putExtra("code",result).putExtra("data",data);startForegroundService(i);toast("Откройте Standoff 2, затем включите AIM в панели");}}
 void toast(String s){Toast.makeText(this,s,Toast.LENGTH_LONG).show();}
}
