import org.antlr.runtime.ANTLRStringStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.TokenStream;
import org.antlr.runtime.tree.BufferedTreeNodeStream;
/*
import org.antlr.runtime.tree.DOTTreeGenerator;
import org.antlr.runtime.tree.Tree;
import org.antlr.stringtemplate.StringTemplate;
*/

public class Vcalc_Test {
    public static void main(String[] args) throws RecognitionException {
    /**
	if (args.length != 2) {
	    System.err.print("Insufficient arguments: ");
	    System.err.println(Arrays.toString(args));
	    System.exit(1);
	}
	**/
	//ANTLRFileStream input = null;
	/*ANTLRStringStream input = new ANTLRStringStream("vector v = 1..6;\n" + 
			"vector b = 2..6;\n" +
			"vector c = b[3..4];\n" +
			"int l = 15;\n" +
			"int i = 2;\n" +
			"vector err = 1..15;\n" + 
			"if (c)\n" +
			"print(b);\n" +
			"fi;\n" +
			"print(v);\n"  +
			"print(b);\n"  +
			"print(c);\n"  +
			"print(v<b);");
			*/
    ANTLRStringStream input = new ANTLRStringStream("vector v1 = 1..10;\n" + 
    		"vector v2 = 2..8;\n" + 
    		"vector v3 = v1 * 2;\n" + 
    		"vector v4 = [i in (v1 * v2) + (v3 / 2) | i * 3 ];\n" + 
    		"vector v5 = filter(i in v4 | (i > 50) * (i < 100) );\n" + 
    		"print(v3);\n" +
    		"print(v1 * v2);\n" +
    		"print(v4);\n" +
    		"print(v5);");
	/**
	try {
	    input = new ANTLRFileStream(args[0]);
	} catch (IOException e) {
	    System.err.print("Invalid program filename: ");
	    System.err.println(args[0]);
	    System.exit(1);
	}
	**/
	vCalcLexer lexer = new vCalcLexer(input);
	TokenStream tokenStream = new CommonTokenStream(lexer);
	vCalcParser parser = new vCalcParser(tokenStream);
	vCalcParser.program_return entry = parser.program();
	Object ast = entry.getTree();
	//System.out.println(entry.tree.toStringTree());
	/*
	DOTTreeGenerator gen = new DOTTreeGenerator();
    StringTemplate st = gen.toDOT((Tree) ast);
    System.out.println(st); 
    */
	BufferedTreeNodeStream nodes = new BufferedTreeNodeStream(ast);
	nodes.setTokenStream(tokenStream);
	
	// Pass over to verify no variable misuse
	//Defined defined = new Defined(nodes);
	//defined.downup(ast);
	
	// nodes.reset();
    Interpreter interpreter = new Interpreter(nodes);
    interpreter.program();
	
	/**
	if (args[1].equals("int")) {
	    // Run it through the Interpreter
	    // nodes.reset();
	    //Interpreter interpreter = new Interpreter(nodes);
	    //interpreter.program();
	}
	else {
	    // Pass it all to the String templater!
	    //String templateFile = args[1] + ".stg";

	    //Reader template = new InputStreamReader(Vcalc_Test.class.getResourceAsStream(templateFile));
	    //StringTemplateGroup stg = new StringTemplateGroup(template);

	    // nodes.reset();
	    //Templater templater = new Templater(nodes);
	    //templater.setTemplateLib(stg);
	    //System.out.println(templater.program().getTemplate().toString());
	}
	**/
    }
}