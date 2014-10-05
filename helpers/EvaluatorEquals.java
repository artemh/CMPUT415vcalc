package helpers;

import java.util.ArrayList;

public class EvaluatorEquals implements Evaluator {
	Type type;
	Evaluator lhs;
	Evaluator rhs;
	
	public EvaluatorEquals(Evaluator lhs, Evaluator rhs)
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
			Integer l = (Integer) lhs.evaluate();
			Integer r = (Integer) rhs.evaluate();
			return (l.compareTo(r) == 0) ? 1 : 0;
		} else if(type.getName().equals("vector")) {
			ArrayList<Integer> result = new ArrayList<Integer>();
			
			// Three cases: (vec == int), (int == vec) and (vec == vec), result is the size of the larger of the two vectors
			// for (int == vec) and (vec == int), promote integer to vector of integer's values.
			// for (vec == vec) pad the smaller vector with zeroes.
			Type lhsType = lhs.getType();
			Type rhsType = rhs.getType();
			if (lhsType.getName().equals("int")) {
				// promote lhs, since we know rhs is a vector
				Integer lhsInt = (Integer)lhs.evaluate();
				ArrayList<Integer> rhsVec = (ArrayList<Integer>)rhs.evaluate();	
				Integer size = rhsVec.size();
				for (int i = 0; i < size; i++) {
					result.add(lhsInt.compareTo(rhsVec.get(i)) == 0 ? 1 : 0);
				}
			} else if (rhsType.getName().equals("int")) {
				// promote rhs, since we know lhs is a vector
				ArrayList<Integer> lhsVec = (ArrayList<Integer>)lhs.evaluate();	
				Integer rhsInt = (Integer)rhs.evaluate();
				Integer size = lhsVec.size();
				// Perform element-wise addition
				for (int i = 0; i < size; i++) {
					result.add(lhsVec.get(i).compareTo(rhsInt) == 0 ? 1 : 0);
				}
			} else {
				// vec == vec
				ArrayList<Integer> lhsVec = (ArrayList<Integer>)lhs.evaluate();
				ArrayList<Integer> rhsVec = (ArrayList<Integer>)rhs.evaluate();	
				Integer size = 0;
				Integer lhsSize = lhsVec.size();
				Integer rhsSize = rhsVec.size();
				if (!lhsSize.equals(rhsSize))	{
					// Need to pad the smaller vector with zeroes
					if (lhsSize.compareTo(rhsSize) < 0) {
						// lhs is smaller
						for (int i = lhsSize; i < rhsSize; i++) {
							lhsVec.add(i,0);
						}
						size = rhsSize;
					} else {
						// rhs is smaller
						for (int i = rhsSize; i < lhsSize; i++) {
							rhsVec.add(i,0);
						}
						size = lhsSize;
					}
				} else {
					size = lhsSize;
				}
				// Perform element-wise comparison
				for (int i = 0; i < size; i++) {
					Integer comp = (lhsVec.get(i).compareTo(rhsVec.get(i)) == 0)? 1 : 0;
					System.out.println(comp);
					System.out.println("WWW");
					result.add(comp);
				}
			}
			
			return result;
		} else {
			throw new RuntimeException("Unrecognized type: " + type.getName());
		}
	}

}
