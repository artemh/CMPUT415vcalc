package helpers;

public class EvaluatorMult implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	EvaluatorMult(Evaluator lhs, Evaluator rhs)
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
