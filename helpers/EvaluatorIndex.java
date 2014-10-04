package helpers;

public class EvaluatorIndex implements Evaluator {
	Type type;
	Evaluator vector;
	Evaluator integer;
	
	EvaluatorIndex(Evaluator vector, Evaluator integer)
	{
		this.vector = vector;
		this.integer = integer;
		type = new BuiltInTypeSymbol("int");
	}
	
	@Override
	public Type getType() {
		return type;
	}

	@Override
	public Object evaluate() {
		return null;
	}

}
