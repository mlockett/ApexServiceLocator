/**
 * @author mlockett
 * @data 2019-01-12
 */
@IsTest
private with sharing class ServiceLocator_Test {

	@IsTest
	static void getInstance_ReturnsCorrectInstance() {
		Object o = (ServiceLocator.IMyTest) ServiceLocator.getInstance(ServiceLocator.IMyTest.class);
		System.assert(o instanceof ServiceLocator.MyTest1);
		System.assert(o instanceof ServiceLocator.IMyTest);
	}

	@IsTest
	static void getInstanceString_ReturnsCorrectInstance() {
		Object o = (ServiceLocator.IMyTest) ServiceLocator.getInstance('ServiceLocator.IMyTest');

		System.assert(o instanceof ServiceLocator.IMyTest);
		System.assert(o instanceof ServiceLocator.MyTest1);

		Integer retVal = ((ServiceLocator.MyTest1) o).doStuff();
		System.assertEquals(1, retVal);
	}

	@IsTest
	static void getInstanceWithNoMatch_ThrowsServiceLocatorMapException() {
		try {
			// input name w/ no map
			Object testObject = (ServiceLocator.INoMapTest) ServiceLocator.getInstance(ServiceLocator.INoMapTest.class);
			System.assert(false, 'Should throw ServiceLocator.MapException');
		}
		catch (ServiceLocator.MapException e) {
			System.assert(true, 'Should throw ServiceLocator.MapException');
		}
	}

	@IsTest
	static void getInstanceWithNoInterface_ThrowsServiceLocatorInterfaceNameException() {
		try {
			// input name w/ no map
			Object o = (ServiceLocator.IMyTest) ServiceLocator.getInstance('Bad Interface name');
			System.assert(false, 'Should throw ServiceLocator.InterfaceNameException');
		}
		catch (ServiceLocator.InterfaceNameException e) {
			System.assert(true, 'Should throw ServiceLocator.InterfaceNameException');
		}
		catch (System.Exception e) {
			System.assert(false, 'Should throw ServiceLocator.InterfaceNameException');
		}
	}

	@IsTest
	static void getInstanceString_ReturnsCorrectInstanceAndCallsInit() {
		Type myTestInterface = Type.forName('ServiceLocator.IMyTest');

		Object myTestObject = (ServiceLocator.IMyTest) ServiceLocator.getInstance(myTestInterface, new Map<String, Object>());

		System.assert(myTestObject instanceof ServiceLocator.MyTest1);
		System.assertEquals(true, ((ServiceLocator.MyTest1) myTestObject).hitInit);
	}

	@IsTest
	static void overWriteMapWorks() {
		ServiceLocator.overwriteMap(ServiceLocator.IMyTest.class, ServiceLocator.MyTest2.class);
		ServiceLocator.IMyTest myTest2ObjectTest = (ServiceLocator.IMyTest) ServiceLocator.getInstance(ServiceLocator.IMyTest.class);

		System.assert(myTest2ObjectTest instanceof ServiceLocator.MyTest2);
		System.assertEquals(2, myTest2ObjectTest.doStuff());
	}

   @IsTest
   static void locateBy_conventionWorks(){
      ServiceLocator.IMyOtherTest result = (ServiceLocator.MyOtherTest)ServiceLocator.getInstance(ServiceLocator.IMyOtherTest.class);
      System.assertNotEquals(null, result);
      System.assertEquals(1, result.doStuff());
   }

	@IsTest
	static void overWriteObjectMapWorks() {
		ServiceLocator.MyTest2 test2 = new ServiceLocator.MyTest2();
		ServiceLocator.overwriteObjectMap(ServiceLocator.IMyTest.class, test2);
		ServiceLocator.IMyTest myTest2ObjectTest = (ServiceLocator.IMyTest) ServiceLocator.getInstance(ServiceLocator.IMyTest.class);

		System.assertEquals(myTest2ObjectTest, test2);
	}
	/*
	@IsTest
	static void mocks_overWriteObjectMapWorks() {
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		ServiceLocator.IMyTest test = mocks.mock(ServiceLocator.IMyTest.class);
		ServiceLocator.MyTest2 test2 = new ServiceLocator.MyTest2();
		ServiceLocator.overwriteObjectMap(ServiceLocator.IMyTest.class, test2);
		ServiceLocator.IMyTest myTest2ObjectTest = (ServiceLocator.IMyTest) ServiceLocator.getInstance(ServiceLocator.IMyTest.class);


		System.assertEquals(myTest2ObjectTest, test2);
	}*/
}