package utils;

import lia.web.utils.ThreadedPage;

/**
 * @author costing
 */
public final class IPClass {
	/**
	 * full IP
	 */
	public String sIP;

	/**
	 * C-class
	 */
	public String sIPCut;

	/**
	 * Host name
	 */
	public String sName;

	/**
	 * Just the domain
	 */
	public String sDomain;

	/**
	 * AS number
	 */
	public String sAS;

	/**
	 * Country
	 */
	public String sCountry;

	/**
	 * Continent
	 */
	public String sContinent;

	/**
	 * @param ip
	 * @param name
	 * @param sAS
	 */
	public IPClass(final String ip, final String name, final String sAS) {
		this.sIP = ip;
		this.sName = name;
		this.sAS = sAS;

		this.sIPCut = sIP.substring(0, sIP.lastIndexOf('.'));
		this.sDomain = IPUtils.getDomain(ip, name);
		this.sCountry = IPUtils.getCountry(ip, name);

		this.sContinent = CountryMap.getContinent(this.sCountry);
	}

	/**
	 * @param ip
	 * @return distance from this IP class to another IPs
	 */
	public double getDistance(final String ip) {
		// same network
		if (similarTo(ip)) {
			return 0;
		}

		final String hostname = ThreadedPage.getHostName(ip).toLowerCase();

		final String domain = IPUtils.getDomain(ip, hostname);

		// same domain
		if (sDomain.endsWith(domain) || domain.endsWith(sDomain)) {
			return 0.1;
		}

		// same AS
		final String as = IPUtils.getAS(ip);

		if (sAS != null && sAS.equals(as)) {
			return 0.15;
		}

		// do we know the RTT between the two endpoints ?

		final double ipDistance = IPUtils.getIPDistance(sIP, ip);

		if (ipDistance >= 0) {
			return 0.15 + Math.min(ipDistance / 100, 0.15);
		}

		final double asDistance = WhoisEntry.getASDistance(sAS, as);

		// same country
		final String country = IPUtils.getCountry(ip, hostname);

		if (sCountry.equals(country)) {
			if (asDistance >= 0)
				return 0.2 + Math.min(asDistance / 100, 0.1);

			return 0.25;
		}

		if (asDistance >= 0) {
			return 0.3 + Math.min(asDistance / 1000, 0.2);
		}

		// same continent
		final String continent = CountryMap.getContinent(country);

		if (sContinent.equals(continent))
			return 0.5;

		// default case: far far away
		return 0.9;
	}

	/**
	 * @param sIP
	 * @return true if in the same C class
	 */
	public boolean similarTo(final String sIP) {
		return sIPCut.equals(sIP.substring(0, sIP.lastIndexOf('.')));
	}

	@Override
	public String toString() {
		return sIP + "/" + sName + "/" + (sAS != null ? sAS : "");
	}

	/**
	 * @param args
	 */
	public static void main(String args[]) {
		String s = "74.125.77.104";
		IPClass ip = new IPClass(s, "google.de", IPUtils.getAS(s));

		System.err.println(ip);

		System.err.println(ip.getDistance("208.117.190.252"));
	}
}
