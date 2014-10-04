package helpers;

public class EvaluatorVec implements Evaluator {
	Type type;
	String name;
	
	EvaluatorVec(String name, Type type)
	{
		this.name = name;
		this.type = type;
	}
	
	@Override
	public Type getType() {
		return type;
	}

	@Override
	public Object evaluate() {
		return null;
	}
}
