package helpers;

import java.util.ArrayList;

public class EvaluatorNotEquals implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	public EvaluatorNotEquals(Evaluator lhs, Evaluator rhs)
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

		if(type.getName().equals("int")) {
			Boolean result = (Integer)lhs.evaluate()!=(Integer)rhs.evaluate();
			return result ? 1 : 0;
		} else if(type.getName().equals("vector")) {
			ArrayList<Integer> result = new ArrayList<Integer>();
			return result;
		} else {
			System.err.println("Unrecognized type: " + type.getName());
			return null;
		}
	}

}
