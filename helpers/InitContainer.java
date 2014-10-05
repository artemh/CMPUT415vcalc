package helpers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.antlr.stringtemplate.StringTemplate;

public class InitContainer {

	public Map<String, StringTemplate> intInits = new HashMap<String, StringTemplate>();
	public Map<String, StringTemplate> vecInits = new HashMap<String, StringTemplate>();
	
	public Map<String, Integer> counters = new HashMap<String, Integer>();
	
	public List<String> intNames = new ArrayList<String>();
	public List<String> vecNames = new ArrayList<String>();

}
