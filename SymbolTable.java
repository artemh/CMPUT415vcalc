import java.util.HashMap;
import java.util.Map;

public class SymbolTable implements Scope {
	Map<String, Symbol> symbols = new HashMap<String, Symbol>();
	Map<String, Object> objects = new HashMap<String, Object>();
	
	public SymbolTable() {
		initTypeSystem();
	}
	
	protected void initTypeSystem() {
		define(new BuiltInTypeSymbol("int"));
	}
	
	public String getScopeName() {
		return "global";
	}
	
	public Scope getEnclosingScope() {
		return null;
	}
	public void define(Symbol sym) {
		symbols.put(sym.name, sym);
		objects.put(sym.name, sym.value);
	}
	
	public Symbol resolve(String name) {
		return symbols.get(name);
	}
	
	public Object getValue(String name) {
		return objects.get(name);
	}
	
	public String toString() { 
		return getScopeName() + ":" + symbols;
	}
}