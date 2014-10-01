import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.Arrays;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.TokenStream;
import org.antlr.runtime.tree.BufferedTreeNodeStream;
/*
import org.antlr.runtime.tree.DOTTreeGenerator;
import org.antlr.runtime.tree.Tree;
import org.antlr.stringtemplate.StringTemplate;
*/
import org.antlr.stringtemplate.StringTemplateGroup;

public class Scalc_Test {
    public static void main(String[] args) throws RecognitionException {
	if (args.length != 2) {
	    System.err.print("Insufficient arguments: ");
	    System.err.println(Arrays.toString(args));
	    System.exit(1);
	}

	ANTLRFileStream input = null;
	try {
	    input = new ANTLRFileStream(args[0]);
	} catch (IOException e) {
	    System.err.print("Invalid program filename: ");
	    System.err.println(args[0]);
	    System.exit(1);
	}

	sCalcLexer lexer = new sCalcLexer(input);
	TokenStream tokenStream = new CommonTokenStream(lexer);
	sCalcParser parser = new sCalcParser(tokenStream);
	sCalcParser.program_return entry = parser.program();
	Object ast = entry.getTree();
	/*
	DOTTreeGenerator gen = new DOTTreeGenerator();
    StringTemplate st = gen.toDOT((Tree) ast);
    System.out.println(st); 
    */
	BufferedTreeNodeStream nodes = new BufferedTreeNodeStream(ast);
	nodes.setTokenStream(tokenStream);
	
	// Pass over to verify no variable misuse
	Defined defined = new Defined(nodes);
	defined.downup(ast);

	if (args[1].equals("int")) {
	    // Run it through the Interpreter
	    // nodes.reset();
	    Interpreter interpreter = new Interpreter(nodes);
	    interpreter.program();
	}
	else {
	    // Pass it all to the String templater!
	    String templateFile = args[1] + ".stg";

	    Reader template = new InputStreamReader(Scalc_Test.class.getResourceAsStream(templateFile));
	    StringTemplateGroup stg = new StringTemplateGroup(template);

	    // nodes.reset();
	    Templater templater = new Templater(nodes);
	    templater.setTemplateLib(stg);
	    System.out.println(templater.program().getTemplate().toString());
	}
    }
}