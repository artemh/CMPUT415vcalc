package helpers;

public class EvaluatorGenerator implements Evaluator {
	Type type;
	Evaluator range;
	Evaluator expression;
	
	public EvaluatorGenerator(Evaluator range, Evaluator expression)
	{
		type = new BuiltInTypeSymbol("vector");
		this.range = range;
		this.expression = expression;
	}
	
	@Override
	public Type getType() {
		return type;
	}

	@Override
	public Object evaluate() {
		Type rtype = range.getType();
		Type etype = expression.getType();
		
		Type integer = new BuiltInTypeSymbol("int");
		Type vector = type;
		
		if (!(rtype.getName().equals(vector.getName()))) {
			throw new RuntimeException("Type check error. Generator's domain must be a vector.");
		}
		if (!(etype.getName().equals(integer.getName()))) {
			throw new RuntimeException("Type check error. Generator's expression must evaluate to an integer.");
		}
		
		return null;
	}

}
