package studio.reverfyx.aimprototype;
public final class AimMath {
 private AimMath() {}
 public static float clamp(float v,float a,float b) { return Math.max(a, Math.min(b,v)); }
 public static boolean eligible(float x,float y,int w,int h,float radius,long age) {
  return Float.isFinite(x) && Float.isFinite(y) && x>=0 && y>=0 && x<w && y<h
   && age>=0 && age<=350 && Math.hypot(x-w/2f,y-h/2f)<=radius;
 }
 public static float correction(float error,float gain,float limit) {
  return Math.abs(error)<3?0:clamp(error*gain,-limit,limit);
 }
}
