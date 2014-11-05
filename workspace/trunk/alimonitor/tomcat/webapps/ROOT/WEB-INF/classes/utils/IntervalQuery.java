package utils;

import java.util.Collection;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import lazyj.Format;

/**
 * @author costing
 *
 */
public class IntervalQuery {

	private static final class Nr implements Comparable<Nr> {
		int i = 0;
		double d = 0;

		boolean bIsInteger = false;
		boolean bIsDouble = false;

		public Nr(final String s) {
			try {
				i = Integer.parseInt(s);

				d = i;

				bIsInteger = true;
			}
			catch (NumberFormatException nfe) {

				try {
					d = Double.parseDouble(s);

					i = (int) d;

					if (d == i) {
						bIsInteger = true;
					}
					else {
						bIsDouble = true;
					}
				}
				catch (NumberFormatException nfe2) {
					// ignore
				}
			}
		}

		public boolean isValid() {
			return bIsInteger || bIsDouble;
		}

		public boolean isInteger() {
			return bIsInteger;
		}

		@Override
		public String toString() {
			if (bIsInteger)
				return (i < 0 ? " " : "") + i;

			return (d < 0 ? " " : "") + d;
		}

		@Override
		public int compareTo(final Nr other) {
			if (this==other)
				return 0;
			
			if (!isValid())
				return -1;

			if (!other.isValid())
				return -1;

			if (bIsInteger && other.isInteger())
				return i - other.i;

			final double diff = d - other.d;

			if (diff < 0)
				return -1;

			if (diff > 0)
				return 1;

			return 0;
		}
		
		@Override
		public boolean equals(final Object obj) {
			if (obj==null || !(obj instanceof Nr))
				return false;
			
			if (this == obj)
				return true;
			
			return compareTo((Nr) obj)==0;
		}
		
		@Override
		public int hashCode(){
			if (bIsInteger)
				return i;
			
			return (int) d;
		}
	}
	
	private static final Pattern NEGATED_LIST = Pattern.compile("!\\s*\\((.*)\\)");

	private static final Pattern LIST_SPLITTER = Pattern.compile("([^,;]+)([,;]|$)");
	
	/**
	 * @param intervalDef
	 * @param fieldName
	 * @return the SQL query
	 */
	public static String numberInterval(final String intervalDef, final String fieldName) {
		String sCond = "";

		String sCondNegate = "";

		if (intervalDef == null || intervalDef.length() == 0)
			return sCond;

		String sArrayToList = intervalDef.replaceAll("(?<=\\d)\\s+(?=\\d)", ",");

		// hack for negating a whole list
		final Matcher mNeg = NEGATED_LIST.matcher(sArrayToList);
		
		final StringBuffer newValue = new StringBuffer();
		
		while (mNeg.find()){			
			String contents = mNeg.group(1);
			
			//System.err.println("Found : "+contents);
			
			Matcher mSplit = LIST_SPLITTER.matcher(contents);
			
			String negatedList = mSplit.replaceAll("!$1,");
			
			//System.err.println("Negated list : "+negatedList);
			
			mNeg.appendReplacement(newValue, negatedList);
		}
		
		mNeg.appendTail(newValue);
		
		final StringTokenizer st = new StringTokenizer(newValue.toString(), ",;");

		while (st.hasMoreTokens()) {
			String sTok = st.nextToken().trim();

			boolean bNegate = false;

			if (sTok.startsWith("!")) {
				bNegate = true;
				sTok = sTok.substring(1).trim();
			}

			String sEl = "";

			int iDashIndex = sTok.indexOf(':');

			if (iDashIndex < 0) {
				iDashIndex = sTok.indexOf('-');

				if (iDashIndex == 0) {
					iDashIndex = sTok.indexOf('-', 2);

					if (iDashIndex < 0)
						iDashIndex = 0;
				}

				if (iDashIndex == 1 && sTok.charAt(0) == '+') {
					sTok = sTok.substring(1);

					iDashIndex = sTok.indexOf('-', 1);
				}
			}

			if (iDashIndex < 0) {
				final Nr nr = new Nr(sTok);

				if (nr.isValid())
					sEl = fieldName + "=" + nr;
			}
			else {
				final Nr n1 = new Nr(sTok.substring(0, iDashIndex).trim());
				final Nr n2 = new Nr(sTok.substring(iDashIndex + 1).trim());

				if (n1.isValid() && n2.isValid()) {
					int cmp = n1.compareTo(n2);

					if (cmp == 0) {
						sEl = fieldName + "=" + n1;
					}
					else if (cmp > 0) {
						sEl = "(" + fieldName + ">=" + n2 + " AND " + fieldName + "<=" + n1 + ")";
					}
					else {
						sEl = "(" + fieldName + ">=" + n1 + " AND " + fieldName + "<=" + n2 + ")";
					}
				}
				else if (n1.isValid())
					sEl = fieldName + ">=" + n1;
				else if (n2.isValid())
					sEl = fieldName + "<=" + n2;
			}

			if (sEl.length() > 0) {
				if (bNegate) {
					if (sCondNegate.length() > 0) {
						sCondNegate += " OR ";
					}

					sCondNegate += sEl;
				}
				else {
					if (sCond.length() > 0)
						sCond += " OR ";

					sCond += sEl;
				}
			}
		}

		if (sCondNegate.length() > 0) {
			if (sCond.length() > 0)
				sCond = "(" + sCond + ") AND NOT (" + sCondNegate + ")";
			else
				sCond = "NOT (" + sCondNegate + ")";
		}

		return sCond;
	}

	/**
	 * @param sURL
	 * @param sKey
	 * @param sValue
	 * @return the extended URL
	 */
	public static String addToURL(final String sURL, final String sKey, final String sValue) {
		String s = sURL;

		if (s.indexOf("?") < 0)
			s += "?";
		else
			s += "&";

		return s + Format.encode(sKey) + "=" + Format.encode(sValue);
	}

	/**
	 * @param sPrev
	 * @param sCond
	 * @return the extended WHERE SQL query part
	 */
	public static String cond(final String sPrev, final String sCond){
		if (sCond == null || sCond.length() == 0)
			return sPrev;

		if (sPrev == null || sPrev.length() == 0 || sPrev.indexOf("WHERE ")<0)
			return (sPrev!=null ? sPrev : "")+" WHERE (" + sCond + ")";

		return sPrev + " AND (" + sCond + ")";
	}

	/**
	 * Convert a collection of numbers in a comma-separated list. 
	 * 
	 * @param values values to export
	 * @return comma-separated list
	 */
	public static String toCommaList(final Collection<Integer> values){
		if (values==null || values.size()==0)
			return "";
		
		final StringBuilder sb = new StringBuilder();
		
		for (final Integer i: values){
			if (sb.length()>0)
				sb.append(", ");
			
			sb.append(i);
		}
		
		return sb.toString();
	}
	
	/**
	 * @param args
	 */
	public static void main(String args[]) {
		System.err.println(numberInterval("1,2,!(3, 4;5 ;6, 11-12 , 13:14 )", "a"));
		
		System.err.println(cond("", numberInterval("!", "a")));
		
		Set<Integer> s = new TreeSet<Integer>();
		
		s.add(Integer.valueOf(2));
		s.add(Integer.valueOf(1));
		
		System.err.println(toCommaList(s));
	}

}
