package helpers;

import java.util.ArrayList;

public class EvaluatorIndex implements Evaluator {
	Type type;
	Evaluator vector;
	Evaluator index;
	
	public EvaluatorIndex(Evaluator vector, Evaluator index)
	{
		this.vector = vector;
		this.index = index;
		
		//Type checking
		Type lhsType = vector.getType();
		Type indexType = index.getType();
		if (!lhsType.getName().equals("vector"))
			{
				throw new RuntimeException("Type check error. Only vectors can be indexed.");
			}
		if ((indexType.getName().equals("vector"))) {
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
			ArrayList<Integer> vecList = (ArrayList<Integer>) vector.evaluate();
			return (vecList.get((Integer)index.evaluate()));
		} else {
			ArrayList<Integer> vecList = (ArrayList<Integer>) vector.evaluate();
			ArrayList<Integer> indexList = (ArrayList<Integer>) index.evaluate();
			ArrayList<Integer> retList = new ArrayList<Integer>();
			for (int i = 0; i < indexList.size(); i++) {
				Integer iter = indexList.get(i);
				if (iter > vecList.size() - 1) { 
					throw new RuntimeException("Vector out of bounds.");
				}
				Integer item = vecList.get(iter);
				retList.add(item);
			}
			return retList;
		}
	}
}
