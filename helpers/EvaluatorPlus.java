package helpers;

public class EvaluatorPlus implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	EvaluatorPlus(Evaluator lhs, Evaluator rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
		Type typeint = new BuiltInTypeSymbol("int");
		Type typevector = new BuiltInTypeSymbol("vector");
		if ((lhs.getType() == typevector) || (rhs.getType() == typevector)) {
			type = typevector;
		} else {
			type = typeint;
		}
	}
	
	@Override
	public Object evaluate() {
		return null;
	}

	@Override
	public Type getType() {
		return type;
	}
}
