package helpers;

import java.util.ArrayList;

public class EvaluatorIndex implements Evaluator {
	Type type;
	Evaluator vector;
	Evaluator index;
	ArrayList<Evaluator> indeces;
	
	public EvaluatorIndex(Evaluator vector, ArrayList<Evaluator> index)
	{
		this.vector = vector;
		this.indeces = index;

		//Type checking
		Type lhsType = vector.getType();
		//Type indexType = index.getType();
		if (!lhsType.getName().equals("vector"))
			{
				throw new RuntimeException("Type check error. Only vectors can be indexed.");
			}
		/**
		if ((indexType.getName().equals("vector"))) {
			type = new BuiltInTypeSymbol("vector");
		} else {
			type = new BuiltInTypeSymbol("int");
		} **/
	}
	
	@Override
	public Type getType() {
		Type vecType = new BuiltInTypeSymbol("vector");
		for(Evaluator index : indeces) {
			if(index.getType().getName().equals("int")) {
				return new BuiltInTypeSymbol("int");
			} else {
				type = vecType;
			}
		}
		return type;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object evaluate() {
		ArrayList<Integer> retVec = new ArrayList<Integer>((ArrayList<Integer>)vector.evaluate());
		
		for(Evaluator index : indeces) {
			if(index.getType().getName().equals("int")) {
				// Get the right item, return it 
				Integer indexInt = (Integer)index.evaluate();
				if (indexInt > retVec.size() - 1) { 
					throw new RuntimeException("Vector out of bounds.");
				}
				type = new BuiltInTypeSymbol("int");
				return retVec.get(indexInt);
			} else {
				// Calculate the new vector, continue.
				ArrayList<Integer> indexList = (ArrayList<Integer>) index.evaluate();
				ArrayList<Integer> inter = new ArrayList<Integer>();
				
				for (int i = 0; i < indexList.size(); i++) {
					Integer iter = indexList.get(i);
					if (iter > retVec.size() - 1) { 
						throw new RuntimeException("Vector out of bounds.");
					}
					Integer item = retVec.get(iter);
					inter.add(item);
				}
				type = new BuiltInTypeSymbol("vector");
				retVec = inter;
			}
		}
		return retVec;
	}
}
