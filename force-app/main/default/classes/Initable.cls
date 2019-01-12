/**
* Interface to indicate a class has an init function that initializes the class
* This is because you can only instantiate classes with parameterless constructors dynamically
 * @author mlockett
 * @data 2018-12-20
 */

public interface Initable {
   void init(Map<String, Object> params);
}