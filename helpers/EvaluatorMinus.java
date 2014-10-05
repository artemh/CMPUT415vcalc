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

	@SuppressWarnings("unchecked")
	@Override
	public Object evaluate() {
		if(type.getName().equals("int")) {
			Integer result = (Integer)lhs.evaluate()-(Integer)rhs.evaluate();
			return result;
		} else if(type.getName().equals("vector")) {
			ArrayList<Integer> result = new ArrayList<Integer>();
			// Three cases: (vec - int), (int-vec) and (vec-vec), result is the size of the larger of the two vectors
			// for (int - vec) and (vec - int), promote integer to vector of integer's values.
			Type lhsType = lhs.getType();
			Type rhsType = rhs.getType();
			if (lhsType.getName().equals("int")) {
				// promote lhs, since we know rhs is a vector
				Integer lhsInt = (Integer)lhs.evaluate();
				ArrayList<Integer> rhsVec = (ArrayList<Integer>)rhs.evaluate();	
				Integer size = rhsVec.size();
				for (int i = 0; i < size; i++) {
					result.add(i,lhsInt - rhsVec.get(i));
				}
			} else if (rhsType.getName().equals("int")) {
				// promote rhs, since we know lhs is a vector
				ArrayList<Integer> lhsVec = (ArrayList<Integer>)lhs.evaluate();	
				Integer rhsInt = (Integer)rhs.evaluate();
				Integer size = lhsVec.size();
				// Perform element-wise addition
				for (int i = 0; i < size; i++) {
					result.add(i,lhsVec.get(i) - rhsInt);
				}
			} else {
				// vec - vec
				ArrayList<Integer> lhsVec = (ArrayList<Integer>)lhs.evaluate();
				ArrayList<Integer> rhsVec = (ArrayList<Integer>)rhs.evaluate();	
				Integer lhsSize = lhsVec.size();
				Integer rhsSize = rhsVec.size();
				// Size needs to be that of the smaller vector, it will determine how many additions we perform 
				Integer smallerSize = lhsSize.compareTo(rhsSize) > 0 ? rhsSize : lhsSize;
				result = (lhsSize.compareTo(rhsSize) > 0) ? lhsVec : rhsVec;
				// Perform element-wise addition
				for (int i = 0; i < smallerSize; i++) {
					result.set(i, lhsVec.get(i) - rhsVec.get(i));
				}
			}
			
			return result;
		} else {
			throw new RuntimeException("Unrecognized type: " + type.getName());
		}
	}

}
