package helpers;

public class EvaluatorGenerator implements Evaluator {
	Type type;
	
	public EvaluatorGenerator(Evaluator range, Evaluator expression)
	{
		type = new BuiltInTypeSymbol("vector");
	}
	
	@Override
	public Type getType() {
		return type;
	}

	@Override
	public Object evaluate() {
		// TODO Auto-generated method stub
		return null;
	}

}
