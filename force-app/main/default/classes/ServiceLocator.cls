/**
 * ServiceLocator class to generate objects based on custom metadata mappings from interfaces to classes
 * @author mlockett
 * @date 2018-11-05
 */

public with sharing class ServiceLocator {

   /**
    * Map used to dynamically overwrite mappings
    */
   private static Map<String, Type> overwrittenMap = new Map<String, Type>();

   /**
    * Map used to dynamically overwrite mappings with specific instance
    */
   private static Map<String, Object> overwrittenObjectMap = new Map<String, Object>();

   /**
    * overwrites map for dynamically changing mapping
    *
    * @param interfaceType
    * @param classType
    */
   public static void overwriteMap(Type interfaceType, Type classType) {
      overwrittenMap.put(interfaceType.getName(), classType);
   }

   /**
    * overwrites map for dynamically changing mapping
    *
    * @param interfaceType
    * @param myObject instance to return
    */
   public static void overwriteObjectMap(Type interfaceType, Object myObject) {
      overwrittenObjectMap.put(interfaceType.getName(), myObject);
   }

   /**
    * returns an object of a concrete class based on the interface
    * note: this might be changed in the future to allow singleton configuration
    *
    * @param interfaceType
    *
    * @return
    */
   public static Object getInstance(Type interfaceType) {

      System.debug('Interface: ' + interfaceType);
      System.debug('overwrittenMap: ' + overwrittenMap);

      String interfaceName = interfaceType.getName();

      // lets user return specific instance for object
      if (overwrittenObjectMap.containsKey(interfaceName)) {
         return overwrittenObjectMap.get(interfaceName);
      }

      if (overwrittenMap.containsKey(interfaceName)) {
         return overwrittenMap.get(interfaceName).newInstance();
      }

      System.debug('interfaceType: ' + interfaceType);

      // get custom metadata mapping
      List<LocatorConfig__mdt> mapping = [
            SELECT InterfaceName__c, ClassName__c
            FROM LocatorConfig__mdt
            WHERE InterfaceName__c = :interfaceName AND IsActive__c = TRUE
      ];

      if (mapping.size() == 1) {
         return Type.forName(mapping[0].ClassName__c).newInstance();
      }

      Integer lastDot = interfaceName.lastIndexOf('.');
      String firstChar = interfaceName.substring(lastDot + 1,lastDot + 2);

      System.debug('charAt: ' + firstChar);

      // attempt using convention of I<ClassName> for interface
      if (firstChar == 'I') {
         String possibleClassName=interfaceName.substring(0, lastDot + 1) + interfaceName.substring(lastDot + 2);
         Type t = Type.forName(possibleClassName);
         if (t != null) {
            return t.newInstance();
         }
      }
      throw new MapException();
   }

   /**
    * returns an object of a concrete class based on the interface name
    * note: this might be changed in the future to allow singleton configuration
    *
    * @param interfaceName
    * @throws InterfaceNameException if interface name does not correspond to an interface
    *
    * @example IMytest test = (ServiceLocator.IMyTest) ServiceLocator.getInstance(ServiceLocator.IMyTest.class);
    *
    * @return
    */
   public static Object getInstance(String interfaceName) {

      Type interfaceType = Type.forName(interfaceName);

      // if there is no Type, Apex implicitly sets myType to null
      if (interfaceType == null) {
         throw new InterfaceNameException();
      }
      return getInstance(interfaceType);
   }

   /**
    * Creates an object of a concrete class based on the interface name, calls it's init method with object list,
    * then returns the object
    *
    * @param interfaceType
    * @param params
    *
    * @return
    */
   public static Object getInstance(Type interfaceType, Map<String, Object> params) {
      Object o = getInstance(interfaceType);
      Initable i = (Initable) o;
      init(i, params);

      return o;
   }

   /**
    * If object is from class that implements Initable, calls init on the object
    * Since apex doesn't support reflection, we can't call a constructor with params; this is a
    * workaround, to initialize the object
    *
    * @param initableObject
    * @param params
    */
   public static void init(Initable initableObject, Map<String, Object> params) {
      initableObject.init(params);
   }

   /**
    * Exception to indicate passed in Interface does not have a class mapped
    */
   public class MapException extends System.Exception {
   }

   /**
    * Exception to indicate passed in Interface name (string) is not the name of an interface
    */
   public class InterfaceNameException extends System.Exception {
   }

   /**
    * because custom metadata cannot be set in Apex tests, we have to have some test data in the class
    */
   public interface IMyTest {
      Integer doStuff();
   }
   public interface IMyOtherTest {
      Integer doStuff();
   }

   public class MyOtherTest implements IMyOtherTest{
      public Integer doStuff(){ return 1;}
   }

   /**
    * because custom metadata cannot be set in Apex tests, we have to have some test data in the class
    */
   public class MyTest1 implements IMyTest, Initable {
      @TestVisible
      Boolean hitInit = false;

      public Integer doStuff() {
         return 1;
      }

      public void init(Map<String, Object> params) {
         hitInit = true;
      }
   }

   /**
    * because custom metadata cannot be set in Apex tests, we have to have some test data in the class
    */
   public class MyTest2 implements IMyTest {
      public Integer doStuff() {
         return 2;
      }
   }
}