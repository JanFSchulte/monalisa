package utils;

import lazyj.Format;
import lazyj.cache.*;
import java.io.*;
import java.util.*;
import lia.Monitor.Store.Fast.DB;

public final class WhoisEntry {

	private static final int WHOIS_CACHE_EXPIRE = 1000 * 60 * 60 * 12;

	private static ExpirationCache<String, WhoisEntry> whoisCache = new ExpirationCache<String, WhoisEntry>(10000);

	public final String country;
	public final String asname;

	private WhoisEntry(final String country, final String asname) {
		this.country = country;
		this.asname = asname;
	}

	public String toString() {
		return country + "," + asname;
	}

	static {
		lazyj.cache.Cache.register("utils.WhoisEntry.whoisCache", whoisCache);
	}

	private static String getWhoisOutput(final String ip) throws Exception {
		final Process child = lia.util.MLProcess.exec(new String[] {
			"/home/monalisa/MLrepository/bin/getBestSE/getBestSE.sh", ip });

		final OutputStream child_out = child.getOutputStream();
		child_out.close();

		final BufferedReader br = new BufferedReader(new InputStreamReader(child.getInputStream()));
		String sLine;

		String result = "";

		while ((sLine = br.readLine()) != null) {
			if (result.length() > 0)
				result = result + '\n' + sLine;
			else
				result = sLine;
		}
		br.close();

		child.waitFor();

		return result;
	}

	public static synchronized WhoisEntry getWhoisEntry(final String ip) {
		final String ipClass = ip.substring(0, ip.lastIndexOf('.'));

		WhoisEntry entry = whoisCache.get(ipClass);

		if (entry == null) {
			System.err.println("Not found: " + ip + ":" + whoisCache.size());

			String line;

			try {
				line = getWhoisOutput(ip).toLowerCase();
			}
			catch (Exception e) {
				System.err.println("Error resolving " + ip + " : " + e);
				return null;
			}

			int idx = line.indexOf(',');

			if (idx > 0) {
				entry = new WhoisEntry(line.substring(0, idx), line.substring(idx + 1));

				whoisCache.put(ipClass, entry, WHOIS_CACHE_EXPIRE);

				System.err.println("resolved: " + entry + ": " + whoisCache.size());
			}
		}

		return entry;
	}

	private static ExpirationCache<String, Double> asDistanceCache = new ExpirationCache<String, Double>(10000);

	public static double getASDistance(final String as1Name, final String as2Name) {
		if (as1Name == null || as2Name == null || as1Name.length() == 0 || as2Name.length() == 0)
			return -1;

		final String as1 = as1Name.toLowerCase();
		final String as2 = as2Name.toLowerCase();

		final String sKey = as1 + "/" + as2;

		Double d = asDistanceCache.get(sKey);

		if (d != null)
			return d.doubleValue();

		final List<String> addrA1 = new ArrayList<String>();
		final List<String> addrA2 = new ArrayList<String>();

		try {
			final BufferedReader br = new BufferedReader(new FileReader(
				"/home/monalisa/MLrepository/bin/getBestSE/list.txt"));

			String sLine;

			while ((sLine = br.readLine()) != null) {
				StringTokenizer st = new StringTokenizer(sLine.toLowerCase(), ",");

				if (st.countTokens() == 3) {
					String sClass = st.nextToken();
					st.nextToken(); // country
					String sAS = st.nextToken();

					if (sAS.equals(as1))
						addrA1.add(sClass);
					if (sAS.equals(as2))
						addrA2.add(sClass);
				}
			}

			br.close();
		}
		catch (Exception e) {
			System.err.println("Cannot read list.txt : " + e);
		}

		if (addrA1.size() == 0 || addrA2.size() == 0) {
			asDistanceCache.put(sKey, Double.valueOf(-1), WHOIS_CACHE_EXPIRE);
			return -1;
		}

		StringBuilder sIP1 = new StringBuilder();

		for (String sClass : addrA1) {
			if (sIP1.length() > 0)
				sIP1.append(',');

			sIP1.append("'").append(Format.escSQL(sClass)).append("'");
		}

		StringBuilder sIP2 = new StringBuilder();

		for (String sClass : addrA2) {
			if (sIP2.length() > 0)
				sIP2.append(',');

			sIP2.append("'").append(Format.escSQL(sClass)).append("'");
		}

		final DB db = new DB(
			"select avg(abs(ft2.hop_rtt-ft1.hop_rtt)) from fdt_tracepath ft1 inner join fdt_tracepath ft2 on ft1.test_id=ft2.test_id "
				+ "and regexp_replace(ft1.hop_ip,'\\.[0-9]+$','') in ("
				+ sIP1
				+ ") and regexp_replace(ft2.hop_ip,'\\.[0-9]+$','') in (" + sIP2 + ");");

		d = -1d;

		if (db.moveNext())
			d = db.getd(1, -1);

		asDistanceCache.put(sKey, Double.valueOf(d), WHOIS_CACHE_EXPIRE);

		return d;
	}
}
