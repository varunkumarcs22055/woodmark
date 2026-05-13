/**
 * FilterSidebar Component
 *
 * Sidebar with category, material, and price range filters.
 * Fetches categories from API. Calls onFilterChange when filters update.
 */

import { useState, useEffect } from 'react';
import { fetchCategories } from '../api';
import { FiFilter, FiX } from 'react-icons/fi';
import './FilterSidebar.css';

const MATERIALS = [
  { value: 'wood', label: 'Wood' },
  { value: 'metal', label: 'Metal' },
  { value: 'fabric', label: 'Fabric' },
  { value: 'leather', label: 'Leather' },
  { value: 'glass', label: 'Glass' },
  { value: 'marble', label: 'Marble' },
  { value: 'rattan', label: 'Rattan' },
  { value: 'plastic', label: 'Plastic' },
];

export default function FilterSidebar({ filters, onFilterChange, mobileOpen, onClose }) {
  const [categories, setCategories] = useState([]);

  useEffect(() => {
    fetchCategories()
      .then(data => setCategories(
        Array.isArray(data) ? data
          : Array.isArray(data?.results) ? data.results : []
      ))
      .catch(err => console.error('Failed to fetch categories:', err));
  }, []);

  const handleCategoryChange = (slug) => {
    onFilterChange({
      ...filters,
      category: filters.category === slug ? '' : slug,
    });
  };

  const handleMaterialChange = (material) => {
    onFilterChange({
      ...filters,
      material: filters.material === material ? '' : material,
    });
  };

  const handlePriceChange = (field, value) => {
    onFilterChange({
      ...filters,
      [field]: value,
    });
  };

  const handleSortChange = (ordering) => {
    onFilterChange({ ...filters, ordering });
  };

  const handlePresetClick = (min, max) => {
    onFilterChange({ ...filters, price_min: min, price_max: max });
  };

  const clearFilters = () => {
    onFilterChange({
      category: '',
      material: '',
      price_min: '',
      price_max: '',
      search: '',
      ordering: '-created_at',
    });
  };

  const PRICE_PRESETS = [
    { label: 'Under ₹10k', min: '', max: '10000' },
    { label: '₹10k–₹30k', min: '10000', max: '30000' },
    { label: '₹30k–₹60k', min: '30000', max: '60000' },
    { label: '₹60k+', min: '60000', max: '' },
  ];

  const hasActiveFilters = filters.category || filters.material ||
    filters.price_min || filters.price_max;

  return (
    <>
      <aside className={`filter-sidebar ${mobileOpen ? 'open' : ''}`} id="filter-sidebar">
        <div className="filter-header">
          <h3 className="filter-title">
            <FiFilter size={18} /> Filters
          </h3>
          <div className="filter-header-actions">
            {hasActiveFilters && (
              <button className="filter-clear-btn" onClick={clearFilters}>
                Clear All
              </button>
            )}
            <button className="filter-close-btn" onClick={onClose}>
              <FiX size={20} />
            </button>
          </div>
        </div>

        {/* Sort By */}
        <div className="filter-section">
          <h4 className="filter-section-title">Sort By</h4>
          <select
            className="form-input filter-sort-select"
            value={filters.ordering || '-created_at'}
            onChange={(e) => handleSortChange(e.target.value)}
          >
            <option value="-created_at">Newest First</option>
            <option value="price">Price: Low to High</option>
            <option value="-price">Price: High to Low</option>
            <option value="name">Name: A to Z</option>
            <option value="-name">Name: Z to A</option>
          </select>
        </div>

        {/* Category Filter */}
        <div className="filter-section">
          <h4 className="filter-section-title">Category</h4>
          <div className="filter-options">
            {categories.map((cat) => (
              <label
                key={cat.id}
                className={`filter-chip ${filters.category === cat.slug ? 'active' : ''}`}
              >
                <input
                  type="radio"
                  name="category"
                  checked={filters.category === cat.slug}
                  onChange={() => handleCategoryChange(cat.slug)}
                />
                {cat.name}
                <span className="filter-chip-count">{cat.product_count}</span>
              </label>
            ))}
          </div>
        </div>

        {/* Material Filter */}
        <div className="filter-section">
          <h4 className="filter-section-title">Material</h4>
          <div className="filter-options filter-chips-grid">
            {MATERIALS.map((mat) => (
              <button
                key={mat.value}
                className={`material-chip ${filters.material === mat.value ? 'active' : ''}`}
                onClick={() => handleMaterialChange(mat.value)}
              >
                {mat.label}
              </button>
            ))}
          </div>
        </div>

        {/* Price Range Filter */}
        <div className="filter-section">
          <h4 className="filter-section-title">Price Range</h4>
          <div className="price-range-inputs">
            <div className="price-input-group">
              <span className="price-symbol">₹</span>
              <input
                type="number"
                placeholder="Min"
                value={filters.price_min}
                onChange={(e) => handlePriceChange('price_min', e.target.value)}
                className="form-input price-input"
                id="filter-price-min"
                min="0"
              />
            </div>
            <span className="price-separator">—</span>
            <div className="price-input-group">
              <span className="price-symbol">₹</span>
              <input
                type="number"
                placeholder="Max"
                value={filters.price_max}
                onChange={(e) => handlePriceChange('price_max', e.target.value)}
                className="form-input price-input"
                id="filter-price-max"
                min="0"
              />
            </div>
          </div>
          <div className="price-presets">
            {PRICE_PRESETS.map((p) => {
              const active = filters.price_min === p.min && filters.price_max === p.max;
              return (
                <button
                  key={p.label}
                  type="button"
                  className={`price-preset-chip ${active ? 'active' : ''}`}
                  onClick={() => handlePresetClick(p.min, p.max)}
                >
                  {p.label}
                </button>
              );
            })}
          </div>
        </div>
      </aside>

      {/* Mobile overlay */}
      {mobileOpen && (
        <div className="filter-overlay" onClick={onClose} />
      )}
    </>
  );
}
