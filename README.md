# Apex Service Locator
A Service Locator library for the force.com platform.
[Service Locator Pattern wikipedia](https://en.wikipedia.org/wiki/Service_locator_pattern)  
This library is most useful for developers that prefer to program against interfaces for loose coupling of code. 
In general, it's not recommended for low-code solutions. It is invaluable when working with larger code bases, 
and when one desires to do _true_ unit testing rather than only integration testing.

## Usage

##### To get an instance of a dependant class inside another class:  
`IMytest test = (ServiceLocator.IMyTest) ServiceLocator.getInstance(ServiceLocator.IMyTest.class);`

To resolve a dependancy, the Service Locator checks these items in order (the first found item wins):
1. The mapping is set explicitly in code
2. The Interface has been explicitly mapped in custom metadata
3. If it follows a convention that can return an object
4. Then finally throws a ServiceLocator.MapException if the Interface cannot be resolved to an object.

##### To test with your own class:
`ServiceLocator.overwriteMap(ServiceLocator.IMyTest.class, ServiceLocator.MyTest2.class);`  

This means when the service locator is called to find a service for IMyTest, it will return an object of type 'MyTest2'

##### To test against a specific object:  
    ServiceLocator.MyTest2 test2 = new ServiceLocator.MyTest2();
    ServiceLocator.overwriteObjectMap(ServiceLocator.IMyTest.class, test2);

This enables you to force the locator to return a specific instance.  
In conjunction with [FinancialForce ApexMocks Framework](https://github.com/financialforcedev/fflib-apex-mocks), you can write code like this:  
    
    fflib_ApexMocks mocks = new fflib_ApexMocks();  
    IMyTest mockTest = (IMyTest) mocks.mock(IMyTest.class);  
    
    // set up mock as desired
    ServiceLocator.overwriteObjectMap(ServiceLocator.IMyTest.class, mockTest);

Now the service locator will use the mocked object.

##### You can configure what service will be found with the Custom metadata type 'LocatorConfig__mdt':  
See the test example in the LocatorConfig__mdt

##### You can also use conventions to locate services
If you have an interface 'IMySpecialThing', and there exists a class 'MySpecialThing', calling the locator for 
IMySpecialThing will return an instance of MySpecialThing (assuming there is no specific configuration in the LocatorConfig
custom metadata object)

##### To instantiate a class with parameters  
Because the Apex language does not fully support reflection, we use a workaround for objects that need parameters to be properly instantiated.

If an Interface resolves to a class that implements "Initable", the service locator can accept a "parameters" argument in the form of a Map<String, Object> where the string is the parameter name and the Object is the value for the parameter. To implement the interface, one must write a method called "init" that takes a Map<String, Object>. The init method should set the appropriate fields in the object based on the specific needs of the class. In this case, the Service Locator, will create the object, then call the init method, passing the map.

In this case, the service locator is called as such:

    Map<String, Object> parameters = new Map<String, Object>();
    parameters.put('myParamName1, 5);
    parameters.put('myParamName2, 'John Doe');
    Object myTestObject = (ServiceLocator.IMyTest) ServiceLocator.getInstance(myTestInterface, parameters);
 		 

## Resources
[Service Locator Pattern wikipedia](https://en.wikipedia.org/wiki/Service_locator_pattern)

## Future
Might enable user to point to a factory class which would build the object as needed

## Discussion  
There are many that feel the service locator pattern is an anti-pattern. I won't jump into that fray, but would point 
out that the Apex language does have strong support for a dependancy injection container as one might see in
Java, C# or other mature object oriented languages. I consider a Service Locator a lesser, but viable, alternative.
