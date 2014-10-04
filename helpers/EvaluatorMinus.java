package helpers;

import java.util.ArrayList;

public class EvaluatorMinus implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	public EvaluatorMinus(Evaluator lhs, Evaluator rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
		if ((lhs.getType().getName().equals("vector")) || (rhs.getType().getName().equals("vector"))) {
			type = new BuiltInTypeSymbol("vector");
		} else {
			type = new BuiltInTypeSymbol("int");
		}
	}
	
	@Override
	public Type getType() {
		return type;
	}

	@Override
	public Object evaluate() {
		if(type.getName().equals("int")) {
			Integer result = (Integer)lhs.evaluate()-(Integer)rhs.evaluate();
			return result;
		} else if(type.getName().equals("vector")) {
			ArrayList<Integer> result = new ArrayList<Integer>();
			return result;
		} else {
			System.err.println("Unrecognized type: " + type.getName());
			return null;
		}
	}

}
