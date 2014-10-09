package helpers;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.antlr.stringtemplate.StringTemplate;

public class InitContainer {

	public Map<String, StringTemplate> inits = new HashMap<String, StringTemplate>();
	public Map<String, Integer> counters = new HashMap<String, Integer>();
	public Map<String, Boolean> types = new HashMap<String, Boolean>();
	
	public List<String> names = new ArrayList<String>();
}
