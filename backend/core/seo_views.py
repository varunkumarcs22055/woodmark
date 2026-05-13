"""
SEO surfaces — sitemap.xml + robots.txt.

Crawlers look for these at the absolute root, so they're mounted in core.urls
(NOT under /api/). They consult FRONTEND_URL because product/category pages
live on the React app, not the Django backend.
"""
from django.conf import settings
from django.http import HttpResponse
from django.utils import timezone

from products.models import Product, Category


def _frontend_base():
    return settings.FRONTEND_URL.rstrip('/')


def robots_txt(request):
    base = _frontend_base()
    body = (
        "User-agent: *\n"
        "Disallow: /admin-dashboard/\n"
        "Disallow: /dealer-dashboard/\n"
        "Disallow: /cart\n"
        "Disallow: /checkout\n"
        "Disallow: /orders\n"
        "Disallow: /login\n"
        "Disallow: /signup\n"
        "Disallow: /forgot-password\n"
        "Disallow: /reset-password\n"
        "Allow: /\n\n"
        f"Sitemap: {base}/sitemap.xml\n"
    )
    return HttpResponse(body, content_type='text/plain')


def sitemap_xml(request):
    """
    Single-file XML sitemap. Lists:
      - homepage
      - each non-deleted, active Product (high priority)
      - each Category landing page (medium priority)

    For sites with >50k URLs we'd switch to a sitemap index, but a furniture
    catalog will fit comfortably in one file for a long time.
    """
    base = _frontend_base()
    now = timezone.now().strftime('%Y-%m-%d')

    parts = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']

    parts.append(
        f'<url><loc>{base}/</loc><lastmod>{now}</lastmod>'
        f'<changefreq>daily</changefreq><priority>1.0</priority></url>'
    )

    cat_qs = Category.objects.all()
    for cat in cat_qs.iterator():
        slug = getattr(cat, 'slug', None) or ''
        if not slug:
            continue
        parts.append(
            f'<url><loc>{base}/?category={slug}</loc>'
            f'<changefreq>weekly</changefreq><priority>0.7</priority></url>'
        )

    qs = Product.objects.all()
    if hasattr(Product, 'is_deleted'):
        qs = qs.filter(is_deleted=False)
    if hasattr(Product, 'status'):
        qs = qs.filter(status='active')

    for p in qs.only('slug', 'updated_at').iterator():
        slug = getattr(p, 'slug', None)
        if not slug:
            continue
        lastmod = (p.updated_at or timezone.now()).strftime('%Y-%m-%d') \
            if hasattr(p, 'updated_at') else now
        parts.append(
            f'<url><loc>{base}/product/{slug}</loc>'
            f'<lastmod>{lastmod}</lastmod>'
            f'<changefreq>weekly</changefreq><priority>0.9</priority></url>'
        )

    parts.append('</urlset>')
    return HttpResponse(''.join(parts), content_type='application/xml')
