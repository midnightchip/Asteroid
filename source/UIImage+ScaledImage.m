@implementation UIImage (ScaledImage)

- (UIImage *)scaleImageToSize:(CGSize)newSize {

  CGRect scaledImageRect = CGRectZero;

  CGFloat aspectWidth = newSize.width / self.size.width;
  CGFloat aspectHeight = newSize.height / self.size.height;
  CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );

  scaledImageRect.size.width = self.size.width * aspectRatio;
  scaledImageRect.size.height = self.size.height * aspectRatio;
  scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
  scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;

  UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
  [self drawInRect:scaledImageRect];
  UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return scaledImage;

}

@end
