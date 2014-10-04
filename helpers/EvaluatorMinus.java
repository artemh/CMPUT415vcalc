package helpers;

public class EvaluatorMinus implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	EvaluatorMinus(Evaluator lhs, Evaluator rhs)
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
	public Type getType() {
		return type;
	}

	@Override
	public Object evaluate() {
		// TODO Auto-generated method stub
		return null;
	}

}
