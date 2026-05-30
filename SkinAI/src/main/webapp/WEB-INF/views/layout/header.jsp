<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<title>Dermify</title>
<meta name='robots' content='max-image-preview:large' />
<link rel="alternate" type="application/rss+xml" title="Dermify &raquo; Feed" href="feed/index.html" />
<link rel="alternate" type="application/rss+xml" title="Dermify &raquo; Comments Feed" href="comments/feed/index.html" />
<link rel="alternate" title="oEmbed (JSON)" type="application/json+oembed" href="wp-json/oembed/1.0/embedb2b4.json?url=https%3A%2F%2Frre-project.site%2Fdermify%2F" />
<link rel="alternate" title="oEmbed (XML)" type="text/xml+oembed" href="wp-json/oembed/1.0/embed2b94?url=https%3A%2F%2Frre-project.site%2Fdermify%2F&amp;format=xml" />


<link rel='stylesheet' id='elementor-frontend-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/frontend.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='elementor-post-407-css' href='${pageContext.request.contextPath}/assets/wp-content/uploads/sites/20/elementor/css/post-4074f34.css?ver=1779863083' media='all' />
<link rel='stylesheet' id='gum-elementor-addon-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/gum-elementor-addon/css/style8717.css?ver=7.0' media='all' />
<link rel='stylesheet' id='elementor-post-408-css' href='${pageContext.request.contextPath}/assets/wp-content/uploads/sites/20/elementor/css/post-4084f34.css?ver=1779863083' media='all' />
<link rel='stylesheet' id='font-awesome-5-all-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/lib/font-awesome/css/all.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='font-awesome-4-shim-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/lib/font-awesome/css/v4-shims.minbfce.css?ver=4.1.0' media='all' />
<style id="wp-emoji-styles-inline-css">

	img.wp-smiley, img.emoji {
		display: inline !important;
		border: none !important;
		box-shadow: none !important;
		height: 1em !important;
		width: 1em !important;
		margin: 0 0.07em !important;
		vertical-align: -0.1em !important;
		background: none !important;
		padding: 0 !important;
	}
/*# sourceURL=wp-emoji-styles-inline-css */
</style>
<style id="global-styles-inline-css">
:root{--wp--preset--aspect-ratio--square: 1;--wp--preset--aspect-ratio--4-3: 4/3;--wp--preset--aspect-ratio--3-4: 3/4;--wp--preset--aspect-ratio--3-2: 3/2;--wp--preset--aspect-ratio--2-3: 2/3;--wp--preset--aspect-ratio--16-9: 16/9;--wp--preset--aspect-ratio--9-16: 9/16;--wp--preset--color--black: #000000;--wp--preset--color--cyan-bluish-gray: #abb8c3;--wp--preset--color--white: #ffffff;--wp--preset--color--pale-pink: #f78da7;--wp--preset--color--vivid-red: #cf2e2e;--wp--preset--color--luminous-vivid-orange: #ff6900;--wp--preset--color--luminous-vivid-amber: #fcb900;--wp--preset--color--light-green-cyan: #7bdcb5;--wp--preset--color--vivid-green-cyan: #00d084;--wp--preset--color--pale-cyan-blue: #8ed1fc;--wp--preset--color--vivid-cyan-blue: #0693e3;--wp--preset--color--vivid-purple: #9b51e0;--wp--preset--gradient--vivid-cyan-blue-to-vivid-purple: linear-gradient(135deg,rgb(6,147,227) 0%,rgb(155,81,224) 100%);--wp--preset--gradient--light-green-cyan-to-vivid-green-cyan: linear-gradient(135deg,rgb(122,220,180) 0%,rgb(0,208,130) 100%);--wp--preset--gradient--luminous-vivid-amber-to-luminous-vivid-orange: linear-gradient(135deg,rgb(252,185,0) 0%,rgb(255,105,0) 100%);--wp--preset--gradient--luminous-vivid-orange-to-vivid-red: linear-gradient(135deg,rgb(255,105,0) 0%,rgb(207,46,46) 100%);--wp--preset--gradient--very-light-gray-to-cyan-bluish-gray: linear-gradient(135deg,rgb(238,238,238) 0%,rgb(169,184,195) 100%);--wp--preset--gradient--cool-to-warm-spectrum: linear-gradient(135deg,rgb(74,234,220) 0%,rgb(151,120,209) 20%,rgb(207,42,186) 40%,rgb(238,44,130) 60%,rgb(251,105,98) 80%,rgb(254,248,76) 100%);--wp--preset--gradient--blush-light-purple: linear-gradient(135deg,rgb(255,206,236) 0%,rgb(152,150,240) 100%);--wp--preset--gradient--blush-bordeaux: linear-gradient(135deg,rgb(254,205,165) 0%,rgb(254,45,45) 50%,rgb(107,0,62) 100%);--wp--preset--gradient--luminous-dusk: linear-gradient(135deg,rgb(255,203,112) 0%,rgb(199,81,192) 50%,rgb(65,88,208) 100%);--wp--preset--gradient--pale-ocean: linear-gradient(135deg,rgb(255,245,203) 0%,rgb(182,227,212) 50%,rgb(51,167,181) 100%);--wp--preset--gradient--electric-grass: linear-gradient(135deg,rgb(202,248,128) 0%,rgb(113,206,126) 100%);--wp--preset--gradient--midnight: linear-gradient(135deg,rgb(2,3,129) 0%,rgb(40,116,252) 100%);--wp--preset--font-size--small: 13px;--wp--preset--font-size--medium: 20px;--wp--preset--font-size--large: 36px;--wp--preset--font-size--x-large: 42px;--wp--preset--spacing--20: 0.44rem;--wp--preset--spacing--30: 0.67rem;--wp--preset--spacing--40: 1rem;--wp--preset--spacing--50: 1.5rem;--wp--preset--spacing--60: 2.25rem;--wp--preset--spacing--70: 3.38rem;--wp--preset--spacing--80: 5.06rem;--wp--preset--shadow--natural: 6px 6px 9px rgba(0, 0, 0, 0.2);--wp--preset--shadow--deep: 12px 12px 50px rgba(0, 0, 0, 0.4);--wp--preset--shadow--sharp: 6px 6px 0px rgba(0, 0, 0, 0.2);--wp--preset--shadow--outlined: 6px 6px 0px -3px rgb(255, 255, 255), 6px 6px rgb(0, 0, 0);--wp--preset--shadow--crisp: 6px 6px 0px rgb(0, 0, 0);}:root { --wp--style--global--content-size: 800px;--wp--style--global--wide-size: 1200px; }:where(body) { margin: 0; }.wp-site-blocks > .alignleft { float: left; margin-right: 2em; }.wp-site-blocks > .alignright { float: right; margin-left: 2em; }.wp-site-blocks > .aligncenter { justify-content: center; margin-left: auto; margin-right: auto; }:where(.wp-site-blocks) > * { margin-block-start: 24px; margin-block-end: 0; }:where(.wp-site-blocks) > :first-child { margin-block-start: 0; }:where(.wp-site-blocks) > :last-child { margin-block-end: 0; }:root { --wp--style--block-gap: 24px; }:root :where(.is-layout-flow) > :first-child{margin-block-start: 0;}:root :where(.is-layout-flow) > :last-child{margin-block-end: 0;}:root :where(.is-layout-flow) > *{margin-block-start: 24px;margin-block-end: 0;}:root :where(.is-layout-constrained) > :first-child{margin-block-start: 0;}:root :where(.is-layout-constrained) > :last-child{margin-block-end: 0;}:root :where(.is-layout-constrained) > *{margin-block-start: 24px;margin-block-end: 0;}:root :where(.is-layout-flex){gap: 24px;}:root :where(.is-layout-grid){gap: 24px;}.is-layout-flow > .alignleft{float: left;margin-inline-start: 0;margin-inline-end: 2em;}.is-layout-flow > .alignright{float: right;margin-inline-start: 2em;margin-inline-end: 0;}.is-layout-flow > .aligncenter{margin-left: auto !important;margin-right: auto !important;}.is-layout-constrained > .alignleft{float: left;margin-inline-start: 0;margin-inline-end: 2em;}.is-layout-constrained > .alignright{float: right;margin-inline-start: 2em;margin-inline-end: 0;}.is-layout-constrained > .aligncenter{margin-left: auto !important;margin-right: auto !important;}.is-layout-constrained > :where(:not(.alignleft):not(.alignright):not(.alignfull)){max-width: var(--wp--style--global--content-size);margin-left: auto !important;margin-right: auto !important;}.is-layout-constrained > .alignwide{max-width: var(--wp--style--global--wide-size);}body .is-layout-flex{display: flex;}.is-layout-flex{flex-wrap: wrap;align-items: center;}.is-layout-flex > :is(*, div){margin: 0;}body .is-layout-grid{display: grid;}.is-layout-grid > :is(*, div){margin: 0;}body{padding-top: 0px;padding-right: 0px;padding-bottom: 0px;padding-left: 0px;}:root :where(.wp-element-button, .wp-block-button__link){background-color: #32373c;border-width: 0;color: #fff;font-family: inherit;font-size: inherit;font-style: inherit;font-weight: inherit;letter-spacing: inherit;line-height: inherit;padding-top: calc(0.667em + 2px);padding-right: calc(1.333em + 2px);padding-bottom: calc(0.667em + 2px);padding-left: calc(1.333em + 2px);text-decoration: none;text-transform: inherit;}.has-black-color{color: var(--wp--preset--color--black) !important;}.has-cyan-bluish-gray-color{color: var(--wp--preset--color--cyan-bluish-gray) !important;}.has-white-color{color: var(--wp--preset--color--white) !important;}.has-pale-pink-color{color: var(--wp--preset--color--pale-pink) !important;}.has-vivid-red-color{color: var(--wp--preset--color--vivid-red) !important;}.has-luminous-vivid-orange-color{color: var(--wp--preset--color--luminous-vivid-orange) !important;}.has-luminous-vivid-amber-color{color: var(--wp--preset--color--luminous-vivid-amber) !important;}.has-light-green-cyan-color{color: var(--wp--preset--color--light-green-cyan) !important;}.has-vivid-green-cyan-color{color: var(--wp--preset--color--vivid-green-cyan) !important;}.has-pale-cyan-blue-color{color: var(--wp--preset--color--pale-cyan-blue) !important;}.has-vivid-cyan-blue-color{color: var(--wp--preset--color--vivid-cyan-blue) !important;}.has-vivid-purple-color{color: var(--wp--preset--color--vivid-purple) !important;}.has-black-background-color{background-color: var(--wp--preset--color--black) !important;}.has-cyan-bluish-gray-background-color{background-color: var(--wp--preset--color--cyan-bluish-gray) !important;}.has-white-background-color{background-color: var(--wp--preset--color--white) !important;}.has-pale-pink-background-color{background-color: var(--wp--preset--color--pale-pink) !important;}.has-vivid-red-background-color{background-color: var(--wp--preset--color--vivid-red) !important;}.has-luminous-vivid-orange-background-color{background-color: var(--wp--preset--color--luminous-vivid-orange) !important;}.has-luminous-vivid-amber-background-color{background-color: var(--wp--preset--color--luminous-vivid-amber) !important;}.has-light-green-cyan-background-color{background-color: var(--wp--preset--color--light-green-cyan) !important;}.has-vivid-green-cyan-background-color{background-color: var(--wp--preset--color--vivid-green-cyan) !important;}.has-pale-cyan-blue-background-color{background-color: var(--wp--preset--color--pale-cyan-blue) !important;}.has-vivid-cyan-blue-background-color{background-color: var(--wp--preset--color--vivid-cyan-blue) !important;}.has-vivid-purple-background-color{background-color: var(--wp--preset--color--vivid-purple) !important;}.has-black-border-color{border-color: var(--wp--preset--color--black) !important;}.has-cyan-bluish-gray-border-color{border-color: var(--wp--preset--color--cyan-bluish-gray) !important;}.has-white-border-color{border-color: var(--wp--preset--color--white) !important;}.has-pale-pink-border-color{border-color: var(--wp--preset--color--pale-pink) !important;}.has-vivid-red-border-color{border-color: var(--wp--preset--color--vivid-red) !important;}.has-luminous-vivid-orange-border-color{border-color: var(--wp--preset--color--luminous-vivid-orange) !important;}.has-luminous-vivid-amber-border-color{border-color: var(--wp--preset--color--luminous-vivid-amber) !important;}.has-light-green-cyan-border-color{border-color: var(--wp--preset--color--light-green-cyan) !important;}.has-vivid-green-cyan-border-color{border-color: var(--wp--preset--color--vivid-green-cyan) !important;}.has-pale-cyan-blue-border-color{border-color: var(--wp--preset--color--pale-cyan-blue) !important;}.has-vivid-cyan-blue-border-color{border-color: var(--wp--preset--color--vivid-cyan-blue) !important;}.has-vivid-purple-border-color{border-color: var(--wp--preset--color--vivid-purple) !important;}.has-vivid-cyan-blue-to-vivid-purple-gradient-background{background: var(--wp--preset--gradient--vivid-cyan-blue-to-vivid-purple) !important;}.has-light-green-cyan-to-vivid-green-cyan-gradient-background{background: var(--wp--preset--gradient--light-green-cyan-to-vivid-green-cyan) !important;}.has-luminous-vivid-amber-to-luminous-vivid-orange-gradient-background{background: var(--wp--preset--gradient--luminous-vivid-amber-to-luminous-vivid-orange) !important;}.has-luminous-vivid-orange-to-vivid-red-gradient-background{background: var(--wp--preset--gradient--luminous-vivid-orange-to-vivid-red) !important;}.has-very-light-gray-to-cyan-bluish-gray-gradient-background{background: var(--wp--preset--gradient--very-light-gray-to-cyan-bluish-gray) !important;}.has-cool-to-warm-spectrum-gradient-background{background: var(--wp--preset--gradient--cool-to-warm-spectrum) !important;}.has-blush-light-purple-gradient-background{background: var(--wp--preset--gradient--blush-light-purple) !important;}.has-blush-bordeaux-gradient-background{background: var(--wp--preset--gradient--blush-bordeaux) !important;}.has-luminous-dusk-gradient-background{background: var(--wp--preset--gradient--luminous-dusk) !important;}.has-pale-ocean-gradient-background{background: var(--wp--preset--gradient--pale-ocean) !important;}.has-electric-grass-gradient-background{background: var(--wp--preset--gradient--electric-grass) !important;}.has-midnight-gradient-background{background: var(--wp--preset--gradient--midnight) !important;}.has-small-font-size{font-size: var(--wp--preset--font-size--small) !important;}.has-medium-font-size{font-size: var(--wp--preset--font-size--medium) !important;}.has-large-font-size{font-size: var(--wp--preset--font-size--large) !important;}.has-x-large-font-size{font-size: var(--wp--preset--font-size--x-large) !important;}
:root :where(.wp-block-icon svg){width: 24px;}
:root :where(.wp-block-pullquote){font-size: 1.5em;line-height: 1.6;}
/*# sourceURL=global-styles-inline-css */
</style>
<link rel='stylesheet' id='template-kit-export-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/template-kit-export/assets/public/template-kit-export-public982a.css?ver=1.0.23' media='all' />
<link rel='stylesheet' id='cute-alert-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/metform/public/assets/lib/cute-alert/styleeda1.css?ver=4.1.4' media='all' />
<link rel='stylesheet' id='text-editor-style-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/metform/public/assets/css/text-editoreda1.css?ver=4.1.4' media='all' />
<link rel='stylesheet' id='hello-elementor-css' href='${pageContext.request.contextPath}/assets/wp-content/themes/hello-elementor/assets/css/reset08cb.css?ver=3.4.9' media='all' />
<link rel='stylesheet' id='hello-elementor-theme-style-css' href='${pageContext.request.contextPath}/assets/wp-content/themes/hello-elementor/assets/css/theme08cb.css?ver=3.4.9' media='all' />
<link rel='stylesheet' id='hello-elementor-header-footer-css' href='${pageContext.request.contextPath}/assets/wp-content/themes/hello-elementor/assets/css/header-footer08cb.css?ver=3.4.9' media='all' />
<link rel='stylesheet' id='elementor-post-24-css' href='${pageContext.request.contextPath}/assets/wp-content/uploads/sites/20/elementor/css/post-244f34.css?ver=1779863083' media='all' />
<link rel='stylesheet' id='owl.carousel-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/gum-elementor-addon/css/owl.carousel8717.css?ver=7.0' media='all' />
<link rel='stylesheet' id='e-animation-fadeIn-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/lib/animations/styles/fadeIn.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='widget-heading-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/widget-heading.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='widget-image-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/widget-image.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='widget-icon-list-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/widget-icon-list.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='metform-ui-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/metform/public/assets/css/metform-uieda1.css?ver=4.1.4' media='all' />
<link rel='stylesheet' id='metform-style-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/metform/public/assets/css/styleeda1.css?ver=4.1.4' media='all' />
<link rel='stylesheet' id='widget-divider-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/widget-divider.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='swiper-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/lib/swiper/v8/css/swiper.min94a4.css?ver=8.4.5' media='all' />
<link rel='stylesheet' id='e-swiper-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/conditionals/e-swiper.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='widget-icon-box-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/widget-icon-box.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='widget-counter-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/widget-counter.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='widget-social-icons-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/widget-social-icons.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='e-apple-webkit-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/css/conditionals/apple-webkit.minbfce.css?ver=4.1.0' media='all' />
<link rel='stylesheet' id='elementor-post-130-css' href='${pageContext.request.contextPath}/assets/wp-content/uploads/sites/20/elementor/css/post-130cbcb.css?ver=1779863084' media='all' />
<link rel='stylesheet' id='ekit-widget-styles-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementskit-lite/widgets/init/assets/css/widget-styles5219.css?ver=3.9.6' media='all' />
<link rel='stylesheet' id='ekit-responsive-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementskit-lite/widgets/init/assets/css/responsive5219.css?ver=3.9.6' media='all' />
<link rel='stylesheet' id='elementor-gf-rethinksans-css' href='https://fonts.googleapis.com/css?family=Rethink+Sans:100,100italic,200,200italic,300,300italic,400,400italic,500,500italic,600,600italic,700,700italic,800,800italic,900,900italic&amp;display=auto' media='all' />
<link rel='stylesheet' id='elementor-gf-fragmentmono-css' href='https://fonts.googleapis.com/css?family=Fragment+Mono:100,100italic,200,200italic,300,300italic,400,400italic,500,500italic,600,600italic,700,700italic,800,800italic,900,900italic&amp;display=auto' media='all' />
<link rel='stylesheet' id='elementor-icons-ekiticons-css' href='${pageContext.request.contextPath}/assets/wp-content/plugins/elementskit-lite/modules/elementskit-icon-pack/assets/css/ekiticons5219.css?ver=3.9.6' media='all' />
<script type='text/javascript'>
		var elementskit = {
			resturl: 'https://rre-project.site/dermify/wp-json/elementskit/v1/',
		}

		</script><script id="font-awesome-4-shim-js" src="${pageContext.request.contextPath}/assets/wp-content/plugins/elementor/assets/lib/font-awesome/js/v4-shims.minbfce.js?ver=4.1.0"></script>
<script id="jquery-core-js" src="${pageContext.request.contextPath}/assets/wp-includes/js/jquery/jquery.minf43b.js?ver=3.7.1"></script>
<script id="jquery-migrate-js" src="${pageContext.request.contextPath}/assets/wp-includes/js/jquery/jquery-migrate.min5589.js?ver=3.4.1"></script>
<script id="template-kit-export-js" src="${pageContext.request.contextPath}/assets/wp-content/plugins/template-kit-export/assets/public/template-kit-export-public982a.js?ver=1.0.23"></script>
<script id="gum-elementor-addon-js" src="${pageContext.request.contextPath}/assets/wp-content/plugins/gum-elementor-addon/js/allscripts5152.js?ver=1.0"></script>
<script id="owl.carousel-js" src="${pageContext.request.contextPath}/assets/wp-content/plugins/gum-elementor-addon/js/owl.carousel.min77e6.js?ver=2.2.1"></script>
<script id="gum-price-table-js" src="${pageContext.request.contextPath}/assets/wp-content/plugins/gum-elementor-addon/js/price-table5152.js?ver=1.0"></script>
<link rel="https://api.w.org/" href="wp-json/index.html" /><link rel="alternate" title="JSON" type="application/json" href="wp-json/wp/v2/pages/130.json" /><link rel="EditURI" type="application/rsd+xml" title="RSD" href="xmlrpc0db0.php?rsd" />
<meta name="generator" content="WordPress 7.0" />
<link rel="canonical" href="index.html" />
<link rel='shortlink' href='index.html' />
<meta name="generator" content="Elementor 4.1.0; features: e_font_icon_svg, additional_custom_breakpoints; settings: css_print_method-external, google_font-enabled, font_display-auto">
			<style>
				.e-con.e-parent:nth-of-type(n+4):not(.e-lazyloaded):not(.e-no-lazyload),
				.e-con.e-parent:nth-of-type(n+4):not(.e-lazyloaded):not(.e-no-lazyload) * {
					background-image: none !important;
				}
				@media screen and (max-height: 1024px) {
					.e-con.e-parent:nth-of-type(n+3):not(.e-lazyloaded):not(.e-no-lazyload),
					.e-con.e-parent:nth-of-type(n+3):not(.e-lazyloaded):not(.e-no-lazyload) * {
						background-image: none !important;
					}
				}
				@media screen and (max-height: 640px) {
					.e-con.e-parent:nth-of-type(n+2):not(.e-lazyloaded):not(.e-no-lazyload),
					.e-con.e-parent:nth-of-type(n+2):not(.e-lazyloaded):not(.e-no-lazyload) * {
						background-image: none !important;
					}
				}
			</style>
			</head>
<body class="home page-template page-template-elementor_header_footer page page-id-130 wp-custom-logo ehf-template-dermify ehf-stylesheet-dermify elementor-default elementor-template-full-width elementor-kit-4 elementor-page elementor-page-130">





