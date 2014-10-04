package helpers;

import java.util.ArrayList;

public class EvaluatorPlus implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	public EvaluatorPlus(Evaluator lhs, Evaluator rhs)
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
		if(type.getName().equals("int")) {
			Integer result = (Integer)lhs.evaluate()+(Integer)rhs.evaluate();
			return result;
		} else if(type.getName().equals("vector")) {
			ArrayList<Integer> result = new ArrayList<Integer>();
			return result;
		} else {
			System.err.println("Unrecognized type: " + type.getName());
			return null;
		}
	}

	@Override
	public Type getType() {
		return type;
	}
}
