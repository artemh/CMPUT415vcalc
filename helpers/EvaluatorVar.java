package helpers;

import java.util.ArrayList;

public class EvaluatorVar implements Evaluator {
	Type type;
	String var;
	Scope scope;
	Symbol symbol;
	
	public EvaluatorVar(Scope scope, String var) {
		this.scope = scope;
		this.var = var;
		symbol = scope.resolve(var);
  		type = symbol.getType();
	}

	@Override
	public Type getType() {
		return type;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object evaluate() {
  		if (type.getName().equals("int")) {
  			Integer value = (Integer)scope.getValue(var);
  			Evaluator eval = new EvaluatorInt(value);
  			return eval.evaluate();
  		} else {
  			ArrayList<Integer> value = (ArrayList<Integer>)scope.getValue(var);
  			Evaluator eval = new EvaluatorVec(value);
  			return eval.evaluate();
  		}
	}

}
