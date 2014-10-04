package helpers;

public class EvaluatorRange implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	EvaluatorRange(Evaluator lhs, Evaluator rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
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
