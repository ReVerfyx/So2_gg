package studio.reverfyx.aimprototype;
import org.junit.Test;
import static org.junit.Assert.*;
public class AimMathTest {
 @Test public void staleOrInvalidTargetsNeverActuate(){
  assertFalse(AimMath.eligible(500,250,1000,500,100,351));
  assertFalse(AimMath.eligible(Float.NaN,250,1000,500,100,0));
  assertFalse(AimMath.eligible(500,250,1000,500,100,-1));
  assertFalse(AimMath.eligible(800,250,1000,500,100,0));
  assertTrue(AimMath.eligible(500,250,1000,500,100,100));
 }
 @Test public void correctionsRespectDirectionDeadzoneAndLimit(){
  assertEquals(-40,AimMath.correction(-1000,.5f,40),0);
  assertEquals(0,AimMath.correction(2,.5f,40),0);
  assertEquals(-10,AimMath.correction(20,-.5f,40),0);
 }
}
