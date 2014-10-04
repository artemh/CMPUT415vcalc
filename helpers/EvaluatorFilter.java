package helpers;

public class EvaluatorFilter implements Evaluator {
	Type type;
	String variable;
	Evaluator range;
	Evaluator expression;
	
	public EvaluatorFilter(String var, Evaluator range, Evaluator expression)
	{
		this.variable = var;
		this.range = range;
		this.expression = expression;
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
