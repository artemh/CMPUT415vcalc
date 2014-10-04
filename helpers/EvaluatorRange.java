package helpers;

import java.util.ArrayList;

public class EvaluatorRange implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	public EvaluatorRange(Evaluator lhs, Evaluator rhs)
	{
		this.lhs = lhs;
		this.rhs = rhs;
		type = new BuiltInTypeSymbol("vector");
		// Type checking
		Type typeint = new BuiltInTypeSymbol("int");
		Type lhsType = lhs.getType();
		Type rhsType = rhs.getType();
		// Is there a better way to do this? Overly verbose.
		if(!lhsType.getName().equals(typeint.getName()) || !rhsType.getName().equals(typeint.getName()))
			{
				System.err.println("Type check error. Range must be specified with integers.");
				System.exit(1);
			}
	}
	
	@Override
	public Type getType() {
		return type;
	}

	@Override
	public Object evaluate() {
		Integer lowerBound = (Integer)lhs.evaluate();
		Integer upperBound = (Integer)rhs.evaluate();
		ArrayList<Integer> vector = new ArrayList<Integer>();
		for (int i = 0; i < (upperBound - lowerBound) + 1; i++){
			vector.add(i, lowerBound+i);
		}
		return vector;
	}
}
