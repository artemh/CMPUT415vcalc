package helpers;

public class EvaluatorLess implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	EvaluatorLess(Evaluator lhs, Evaluator rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
		type = new BuiltInTypeSymbol("int");
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
