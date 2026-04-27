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
      .then(data => setCategories(data))
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

  const clearFilters = () => {
    onFilterChange({
      category: '',
      material: '',
      price_min: '',
      price_max: '',
      search: '',
    });
  };

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
              />
            </div>
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
