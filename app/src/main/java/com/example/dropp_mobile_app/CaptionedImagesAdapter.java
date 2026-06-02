package com.example.dropp_mobile_app;

import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

public class CaptionedImagesAdapter extends RecyclerView.Adapter<CaptionedImagesAdapter.ViewHolder> {
    private Products[] products;

    public CaptionedImagesAdapter(Products[] products) {
        this.products = products;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.card_captioned_image, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        Products product = products[position];
        Drawable drawable = ContextCompat.getDrawable(holder.itemView.getContext(), product.getImgID());
        holder.imageView.setImageDrawable(drawable);
        holder.nameView.setText(product.getName());
        holder.descriptionView.setText(product.getDescription());
        holder.priceView.setText(product.getPrice());
    }

    @Override
    public int getItemCount() {
        return products.length;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView imageView;
        TextView nameView;
        TextView descriptionView;
        TextView priceView;

        public ViewHolder(View itemView) {
            super(itemView);
            imageView = itemView.findViewById(R.id.image);
            nameView = itemView.findViewById(R.id.product_name);
            descriptionView = itemView.findViewById(R.id.product_description);
            priceView = itemView.findViewById(R.id.product_price);
        }
    }
}