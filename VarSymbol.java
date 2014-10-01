public class VarSymbol extends Symbol {
	public VarSymbol(String name, Type type) {
		super(name, type);
	}
	
	public VarSymbol(String name, Type type, Integer value) {
		super(name, type, value);
	}
	
	public VarSymbol(String name, Type type, String location) {
		super(name, type, location);
	}
}
