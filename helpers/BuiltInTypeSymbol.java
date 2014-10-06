package helpers;
public class BuiltInTypeSymbol extends Symbol implements Type {
	public BuiltInTypeSymbol(String name) {
		super(name);
	}
	
	public Boolean equals(Type type) {
		if (this.getName().equals(type.getName())) {
			return true;
		}
		return false;
	}
}
