package helpers;
public interface Scope {
	public String getScopeName();
	public Scope getEnclosingScope();
	public void define(Symbol sym);
	public Symbol resolve(String name);
	public Object getValue(String name);
	public void setValue(String name, Object value);
}