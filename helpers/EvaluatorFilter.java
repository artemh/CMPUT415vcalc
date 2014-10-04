package helpers;

public class EvaluatorFilter implements Evaluator {
	Type type;
	String variable;
	Evaluator range;
	Evaluator expression;
	BaseScope scope;
	
	public EvaluatorFilter(String var, Evaluator range, Evaluator expression, BaseScope scope)
	{
		this.variable = var;
		this.range = range;
		this.expression = expression;
		this.scope = scope;
		type = new BuiltInTypeSymbol("vector");
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
