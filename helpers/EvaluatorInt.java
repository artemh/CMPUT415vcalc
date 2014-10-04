package helpers;

public class EvaluatorInt implements Evaluator {
	Type type;
	Integer value;
	
	public EvaluatorInt(Integer value)
	{
		this.value = value;
		type = new BuiltInTypeSymbol("int");
	}
	
	@Override
	public Object evaluate() {
		return value;
	}
	
	@Override
	public Type getType() {
		return type;
	}
}
