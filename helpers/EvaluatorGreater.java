package helpers;

import java.util.ArrayList;

public class EvaluatorGreater implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	public EvaluatorGreater(Evaluator lhs, Evaluator rhs)
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
			Integer l = (Integer) lhs.evaluate();
			Integer r = (Integer) rhs.evaluate();
			return (l.compareTo(r) > 0) ? 1 : 0;
		} else if(type.getName().equals("vector")) {
			ArrayList<Integer> result = new ArrayList<Integer>();
			return result;
		} else {
			System.err.println("Unrecognized type: " + type.getName());
			return null;
		}
	}
}


