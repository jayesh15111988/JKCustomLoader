# JKCustomLoader
An iOS Custom loader implemented using layer mask

Demo : 

![alt text][CustomLoaderDemo]

This is custom loaded library based on the reference from book _'iOS Core Animation: Advanced Techniques'_ by _'Nick Lockwood'_. All animations are based on the mask property of CALayer object. Mask is initially set to zero and then incremented to increase visible portion of the underlying layer.

Mask Types : 

1. Rectangle - Mask is created in Rectangular form
2. Circular - Mask is created in circular form
3. Triangular - Mask is created in the triangular form
4. Polygon - Mask is created in the polygon format

 There are following parameter user can specify while applying polygon mask :
 - Number of polygon shape vertices
 - Pointiness of polygon edges - This will determine sharpness of an individual polygon edge
 
5. Image
 - Image will also act as a mask. The best way to apply this effect is to use image with transparent background. This will create perfect overlay shape on the underlying layer and create animation as if image mask is exposing the layer lying beneath it.

>Note : User can also set the parameter as number of frames per second. To smoothen animation experience, this value is set to standard value of 60 FPS. It is customizable

Besides it, default values of parameters used in this library are as follows :

 - numberOfVertices - 5
 - pointiness Index for polygon shape - 2
 - Frame rate - 60

 **Update**

 - maskSizeIncrementPerFrame - Mask will evolve in terms of size over time. This parameter will specify the rate of increase of mask per frame. For example, if frame rate is f FPS and maskSizeIncrementParameter is n, mask size will increase by n*f pixels per second (Default value : 2)

Example : Say you have view _testImageView_ thatyou wish to animate.
Simple create an instance of JKCustomLoader with specified view and animation type chosen from types specified above. For simility's sake, let's create one with circulat animation.

```JKCustomLoader* loader = [[JKCustomLoader alloc] initWithInputView:self.testImageView andAnimationType:MaskShapeTypeCircle]; ```

Now call the method 
```loadViewWithPartialCompletionBlock``` to perform an animation as follows, 

```[loader loadViewWithPartialCompletionBlock:^(CGFloat partialCompletionPercentage) {NSLog(@"Percentage Completed %f", partialCompletionPercentage); } andCompletionBlock:^{ NSLog(@"Image Loading Completed"); }]; ```

- First block will give you a number based on the part of animation that has been completed
- Second block will give callback once view has completed animation

__Special Thanks to blog post <a href='http://sketchytech.blogspot.com/2014/11/swift-stars-in-our-paths-cgpath.html'> HERE </a> for showing a way to draw star with the help of a bezier path__



[CustomLoaderDemo]: https://github.com/jayesh15111988/JKCustomLoader/blob/master/Screenshots/MaskAnimationTrimmed.gif "Custom Loader Demo"
