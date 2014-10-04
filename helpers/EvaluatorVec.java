package helpers;

import java.util.ArrayList;

public class EvaluatorVec implements Evaluator {
	Type type;
	ArrayList<Integer> value;
	
	public EvaluatorVec(ArrayList<Integer> value)
	{
		this.value = value;
		type = new BuiltInTypeSymbol("vector");
	}

	@Override
	public Object evaluate() {
		return value;
	}

	@Override
	public Type getType() {
		return type;
	}
}
