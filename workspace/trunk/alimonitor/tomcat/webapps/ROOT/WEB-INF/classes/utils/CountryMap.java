package utils;

import java.io.*;
import java.util.*;

/**
 * @author costing
 *
 */
/**
 * @author costing
 */
public final class CountryMap {

	private CountryMap() {
		// disabled
	}

	private static final HashMap<String, String> countryMap = new HashMap<String, String>();

	static {
		try {
			final BufferedReader br = new BufferedReader(new FileReader(
				"/home/monalisa/MLrepository/bin/getBestSE/countries.txt"));

			String sLine;

			while ((sLine = br.readLine()) != null) {
				final StringTokenizer st = new StringTokenizer(sLine.toLowerCase());

				if (st.countTokens() < 2)
					continue;

				final String continent = st.nextToken();
				final String country = st.nextToken();

				countryMap.put(country, continent);
			}

			br.close();
		}
		catch (Exception e) {
			System.err
				.println("Cannot read countries list from /home/monalisa/MLrepository/bin/getBestSE/countries.txt because "
					+ e);
			e.printStackTrace();
		}
	}

	/**
	 * @param country
	 * @return continent of a country
	 */
	public static String getContinent(final String country) {
		if (country == null || country.length() == 0)
			return country;

		final String continent = countryMap.get(country.toLowerCase());

		if (continent == null)
			return country;

		return continent;
	}

}
