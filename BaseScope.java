import java.util.LinkedHashMap;
import java.util.Map;

public abstract class BaseScope implements Scope {
	Scope enclosingScope;
	Map<String, Symbol> symbols = new LinkedHashMap<String, Symbol>();
	Map<String, Object> objects = new LinkedHashMap<String, Object>();
	
	public BaseScope(Scope enclosingScope) {
		this.enclosingScope = enclosingScope;
	}
	
	public Symbol resolve(String name) {
		Symbol s = symbols.get(name);
		if (s != null) {
			return s;
		}
		if (enclosingScope != null) {
			return enclosingScope.resolve(name);
		}
		return null;
	}
	
	public Object getValue(String name) {
		Object s = objects.get(name);
		if (s != null) {
			return s;
		}
		if (enclosingScope != null) {
			return enclosingScope.getValue(name);
		}
		return null;
	}
	
	public void define(Symbol s) {
		s.scope = this;
		symbols.put(s.name, s);
		objects.put(s.name, s.value);
	}
	
	public Scope getEnclosingScope() {
		return enclosingScope;
	}
	
	public String toString() {
		return symbols.keySet().toString();
	}
}
