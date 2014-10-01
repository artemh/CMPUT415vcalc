public class Symbol {
	public String name;
	public Type type;
	public Object value;
	public String location;
	
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
	
	public Symbol(String name, Type type, String location) {
		this.name = name;
		this.type = type;
		this.location = location;
	}
	
	public String getName() { 
		return name;
	}
	
	public String toString() {
		if ( type != null ) { 
			return '<' + getName() + ":" + type + '>';
		} else {
			return getName();
		}
	}
}