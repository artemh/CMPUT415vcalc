package helpers;
public class Symbol {
	public String name;
	public Type type;
	public Object value;
	public Scope scope;
	
	public Symbol(String name) {
		this.name = name;
	}
	
	public Symbol(String name, Type type) {
		this.name = name;
		this.type = type;
	}
	
	public Symbol(String name, Object value) {
		this.name = name;
		this.value = value;
	}
	
	public Symbol(String name, Type type, Object value) {
		this.name = name;
		this.type = type;
		this.value = value;
	}
	
	public String getName() { 
		return name;
	}
	
	public Type getType() {
		return type;
	}
	
	public String toString() {
		if ( type != null ) { 
			return '<' + getName() + ":" + type + '>';
		} else {
			return getName();
		}
	}
}