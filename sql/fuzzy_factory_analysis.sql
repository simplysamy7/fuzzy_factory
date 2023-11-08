-- MID COURSE PROJECT: Date-'2012-11-27'


-- 1. Gsearch seems to be the biggest driver of our business. 
--  Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?

SELECT
	MONTH(website_sessions.created_at) AS month_wise,
	COUNT(website_sessions.website_session_id) AS total_sessions,
    COUNT(orders.order_id) AS total_orders,
    COUNT(orders.order_id)/COUNT(website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
WHERE
	website_sessions.created_at <'2012-11-27'
    AND utm_source='gsearch'
GROUP BY 1;

-- 2. Pull up monthly trend for gsearch but brand and non-brand campaigns separately
SELECT
	MONTH(website_sessions.created_at) AS month_wise,
	COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_orders
FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
WHERE
	website_sessions.created_at <'2012-11-27'
    AND utm_source='gsearch'
GROUP BY 1;


-- 3. Pull up nonbrand monthly sessions and orders splitted by device type
 SELECT 
	MONTH(website_sessions.created_at) AS month_wise,
    COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(DISTINCT CASE WHEN device_type='mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders,
	COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(DISTINCT CASE WHEN device_type='desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    COUNT(DISTINCT CASE WHEN device_type='mobile' THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_conv_rate,
	COUNT(DISTINCT CASE WHEN device_type='desktop' THEN orders.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_conv_rate
FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
WHERE
	website_sessions.created_at <'2012-11-27'
    AND utm_source='gsearch'
GROUP BY 1;

-- 4. Pull up monthly trends for gsearch as well as monthly trends from other channels
SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE
	website_sessions.created_at <'2012-11-27';
    
-- campaigns apart from gserach brand and nonbrand are, bsearch brand and nonbrand
SELECT
	MONTH(website_sessions.created_at) AS month_wise,
	COUNT(DISTINCT CASE WHEN utm_source='gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source='bsearch'THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
WHERE
	website_sessions.created_at <'2012-11-27'
GROUP BY 1;

-- 5. Pull up session to order conversion rates by month

use mavenfuzzyfactory;

SELECT
	MONTH(website_sessions.created_at) AS months,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessionss,
    COUNT(DISTINCT orders.order_id) AS orderss,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate
FROM website_sessions
	LEFT JOIN orders ON website_sessions.website_session_id=orders.website_session_id
WHERE
	website_sessions.created_at <'2012-11-27'
GROUP BY 1;


-- 6. Estimate revenue earned through gsearch lander test using nonbrand sessions & revenue. See rise in coversion rates intest period
-- Test period - (July 19-July 28) 

-- finding first pageview of url '/lander-1'
-- finding first pageview for each session
-- determining which pageviews ended in 'lander-1' or '/home'
-- make a table to bring in the orders
-- find the difference between landing page conversion rates


-- finding first pageview of url '/lander-1'
SELECT
	MIN(website_pageviews.created_at) AS first_created,
    MIN(website_pageviews.website_pageview_id) AS first_pageview
FROM website_pageviews
	LEFT JOIN website_sessions ON website_pageviews.website_session_id=website_sessions.website_session_id
WHERE
	website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
    AND website_pageviews.pageview_url='/lander-1';
-- first pageview for '/lander-1'=23504


-- finding first pageview for each session  and creating temporary table
CREATE TEMPORARY TABLE first_pageviewed1
SELECT
    website_pageviews.website_session_id AS sessionn,
	MIN(website_pageviews.website_pageview_id) AS first_pageview
FROM website_pageviews
	INNER JOIN website_sessions ON website_pageviews.website_session_id=website_sessions.website_session_id
WHERE 
    website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
    AND website_pageviews.website_pageview_id>=23504
    AND website_pageviews.created_at < '2012-07-28'
GROUP BY 1;

SELECT *
FROM first_pageviewed1;

-- determining which pageviews ended in 'lander-1' or '/home' and creating temporary table
CREATE TEMPORARY TABLE sessions_w_lander1_home
SELECT 
	first_pageviewed1.sessionn,
    website_pageviews.pageview_url
FROM first_pageviewed1
	LEFT JOIN website_pageviews ON first_pageviewed1.first_pageview=website_pageviews.website_pageview_id
WHERE 
	website_pageviews.pageview_url IN ('/lander-1','/home');
    
SELECT *
FROM sessions_w_lander1_home;
    
-- make a table to bring in the orders
CREATE TEMPORARY TABLE sessions_n_orders
SELECT
	sessions_w_lander1_home.sessionn,
    sessions_w_lander1_home.pageview_url,
    orders.order_id
FROM sessions_w_lander1_home
	LEFT JOIN orders ON sessions_w_lander1_home.sessionn=orders.website_session_id;
    
-- finding conversion rates from sessions to orders
SELECT
	pageview_url AS landing_page,
    COUNT(DISTINCT sessionn) AS no_of_sessions,
    COUNT(DISTINCT order_id) AS no_of_orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT sessionn) AS conversion_rate
FROM sessions_n_orders
GROUP BY 1;

-- RESULT: conversion rate for '/home' is 0.0318 and for '/lander-1' is 0.0406. Around 0.0087 rates more.

-- finding the most recent pageview for gsearch nonbrand where traffic was sent to home
SELECT
	MAX(website_sessions.website_session_id) AS most_recent_home_pageview
FROM website_sessions
	LEFT JOIN website_pageviews ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE website_pageviews.pageview_url='/home'
	AND website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
    AND website_sessions.created_at<'2012-11-27';
    
-- most recent session is 17145

SELECT
	COUNT(website_session_id) As no_of_sessions
FROM website_sessions
WHERE website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
    AND website_sessions.created_at<'2012-11-27'
    AND website_session_id >17145;
    
-- No. of sessions since the test is 22972 
-- increase rate is 0.0087 thus 0.0087*17145=202 incremental orders since 29/7/2012. So 200 orders extra in 4 months
	

-- SHOW FULL CONVERSION FUNNEL FOR THE LANDING PAGES FROM THE PREVIOUS QUESTION

-- Step 1: select all pageview for relevant sessions
CREATE TEMPORARY TABLE pageview_level2
SELECT	
    website_session_id,
    MAX(home_page) AS made_it_to_homepage,
    MAX(custom_lander_page) AS made_it_to_custom_lander,
	MAX(products_page) AS made_it_to_product,
    MAX(the_orginal_fuzzy_page) AS made_it_to_fuzzy,
    MAX(cart_page) AS made_it_to_cart,
    MAX(shipping_page) AS made_it_to_shipping,
    MAX(billing_page) AS made_it_to_billing,
    MAX(thank_you_page) AS thank_you_page
FROM(
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
	website_pageviews.created_at,
    CASE WHEN website_pageviews.pageview_url='/home' THEN 1 ELSE 0 END AS home_page,
    CASE WHEN website_pageviews.pageview_url='/lander-1' THEN 1 ELSE 0 END AS custom_lander_page,
    CASE WHEN website_pageviews.pageview_url='/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN website_pageviews.pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS the_orginal_fuzzy_page,
	CASE WHEN website_pageviews.pageview_url='/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN website_pageviews.pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN website_pageviews.pageview_url='/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN website_pageviews.pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
FROM website_sessions
	 LEFT JOIN website_pageviews ON website_sessions.website_session_id=website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-07-28' AND website_sessions.created_at >'2012-06-19'
    AND website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
ORDER BY
	1,2,3
    ) AS pageview_level2

GROUP BY 1;

-- viewing the table created 
SELECT *
FROM pageview_level2;

-- calculating funnel conversion


SELECT 
	CASE 
		WHEN made_it_to_homepage=1 THEN 'homepage'
		WHEN made_it_to_custom_lander=1 THEN 'new lander'
		ELSE 'logic gone wrong' 
	END AS homepage_type,
	COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN made_it_to_product=1 THEN website_session_id ELSE NULL END) AS reached_prodcts,
	COUNT(DISTINCT CASE WHEN made_it_to_fuzzy=1 THEN website_session_id ELSE NULL END) AS mrfuzzy_page,
	COUNT(DISTINCT CASE WHEN made_it_to_cart=1 THEN website_session_id ELSE NULL END) AS cart_page,
	COUNT(DISTINCT CASE WHEN made_it_to_shipping=1 THEN website_session_id ELSE NULL END) AS shipping_page,
	COUNT(DISTINCT CASE WHEN made_it_to_billing=1 THEN website_session_id ELSE NULL END) AS billing_page,
	COUNT(DISTINCT CASE WHEN thank_you_page=1 THEN website_session_id ELSE NULL END) AS thankyou_page
FROM pageview_level2
GROUP BY 1;

-- calculating final click rates
SELECT
	CASE 
		WHEN made_it_to_homepage=1 THEN 'homepage'
		WHEN made_it_to_custom_lander=1 THEN 'new lander'
		ELSE 'logic gone wrong' 
	END AS homepage_type,
        COUNT(DISTINCT CASE WHEN made_it_to_product=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS product_click_rate,
		COUNT(DISTINCT CASE WHEN made_it_to_fuzzy=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN made_it_to_product=1 THEN website_session_id ELSE NULL END) AS fuzzy_click_rate,
		COUNT(DISTINCT CASE WHEN made_it_to_cart=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN made_it_to_fuzzy=1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
		COUNT(DISTINCT CASE WHEN made_it_to_shipping=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN made_it_to_cart=1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
		COUNT(DISTINCT CASE WHEN made_it_to_billing=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN made_it_to_shipping=1 THEN website_session_id ELSE NULL END) AS billing_click_rate,
        COUNT(DISTINCT CASE WHEN thank_you_page=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN made_it_to_billing=1 THEN website_session_id ELSE NULL END) AS thank_you_click_rate
	FROM 
		pageview_level2
	GROUP BY 1;
    

-- quantify the impact of billing test (Sept 10-Nov 10) in terms of revenue per billing page session
-- also pull the number of billing page sessions for the past month to understand the monthly impact 
SELECT 
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM (
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id,
	orders.price_usd
FROM website_pageviews
    LEFT JOIN orders 
    ON website_pageviews.website_session_id=orders.website_session_id
WHERE 
    website_pageviews.created_at <'2012-09-10' AND website_pageviews.created_at <'2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
    ) AS billing_pageviews_and_orders_data
GROUP BY 1;





