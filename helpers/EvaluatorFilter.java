package helpers;

import java.util.ArrayList;

public class EvaluatorFilter implements Evaluator {
	Type type;
	Evaluator range;
	Evaluator expression;
	Scope scope;
	String var;
	
	public EvaluatorFilter(Scope scope, String var, Evaluator range, Evaluator expression)
	{
		type = new BuiltInTypeSymbol("vector");
		this.range = range;
		this.expression = expression;
		this.scope = scope;
		this.var = var;
	}
	
	@Override
	public Type getType() {
		return type;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object evaluate() {
		Type rtype = range.getType();
		Type etype = expression.getType();
		
		Type integer = new BuiltInTypeSymbol("int");
		Type vector = type;
		
		if (!(rtype.getName().equals(vector.getName()))) {
			throw new RuntimeException("Type check error. Filter's domain must be a vector.");
		}
		if (!(etype.getName().equals(integer.getName()))) {
			throw new RuntimeException("Type check error. Filter's expression must evaluate to an integer.");
		}
		
		ArrayList<Integer> rlist = (ArrayList<Integer>)range.evaluate();
		ArrayList<Integer> result = new ArrayList<Integer>();
		
		for (int i : rlist) {
			scope.setValue(var, i);
			Integer comp = (Integer)expression.evaluate();
			if(comp != 0) {result.add(i);}
		}
		
		return result;
	}

}
